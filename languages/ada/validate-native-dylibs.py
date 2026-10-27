"""Validate the authentic ARM bootstrap's existing relative Mach-O references.
No binaries are rewritten. Unknown metadata, escaping paths, missing targets,
and distinct conflicting candidates fail before the native compiler build.
"""
import json
from pathlib import Path
import struct
import sys

ARM64 = 0x0100000C

EXPECTED_LIBRARIES = frozenset({
    'lib/gcc/aarch64-apple-darwin23.2.0/13.2.0/adalib/libgnarl-13.dylib',
    'lib/gcc/aarch64-apple-darwin23.2.0/13.2.0/adalib/libgnat-13.dylib',
    'lib/libatomic.1.dylib', 'lib/libgcc_s.1.1.dylib', 'lib/libgomp.1.dylib',
    'lib/libitm.1.dylib', 'lib/libquadmath.0.dylib', 'lib/libssp.0.dylib',
    'lib/libstdc++.6.dylib',
})
UNSUPPORTED_DEPENDENCY_COMMANDS = frozenset({0x80000018, 0x8000001F, 0x80000023, 0x20})


def commands(path):
    data = path.read_bytes()
    if data[:4] == b'\xca\xfe\xba\xbe':
        if len(data) < 8:
            raise ValueError(f'truncated fat header: {path}')
        count = struct.unpack_from('>I', data, 4)[0]
        if count != 1 or len(data) < 28:
            raise ValueError(f'unsupported universal archive member: {path}')
        cpu, _, offset, size, _ = struct.unpack_from('>IIIII', data, 8)
        if cpu != ARM64 or offset + size > len(data):
            raise ValueError(f'invalid ARM slice: {path}')
        data = data[offset:offset + size]
    if len(data) < 32 or data[:4] != b'\xcf\xfa\xed\xfe':
        raise ValueError(f'unsupported Mach-O member: {path}')
    _, cpu, _, filetype, count, size, _, _ = struct.unpack_from('<8I', data)
    if cpu != ARM64 or filetype != 6 or size > len(data) - 32:
        raise ValueError(f'invalid ARM dylib header: {path}')
    offset = 32
    result = []
    for _ in range(count):
        if offset + 8 > 32 + size:
            raise ValueError(f'truncated load command: {path}')
        command, length = struct.unpack_from('<II', data, offset)
        if length < 8 or offset + length > 32 + size:
            raise ValueError(f'invalid load command length: {path}')
        if command in UNSUPPORTED_DEPENDENCY_COMMANDS:
            raise ValueError(f'unsupported dependency command {command:#x}: {path}')
        if command in (0xC, 0xD, 0x8000001C):
            minimum = 24 if command in (0xC, 0xD) else 12
            if length < minimum:
                raise ValueError(f'truncated path command: {path}')
            string_offset = struct.unpack_from('<I', data, offset + 8)[0]
            if not minimum <= string_offset < length:
                raise ValueError(f'invalid path offset: {path}')
            raw = data[offset + string_offset:offset + length]
            end = raw.find(b'\0')
            if end < 0:
                raise ValueError(f'unterminated load path: {path}')
            result.append((command, raw[:end].decode('utf-8')))
        offset += length
    if offset != 32 + size:
        raise ValueError(f'load command size mismatch: {path}')
    return result


def validate(root):
    root = root.resolve(strict=True)
    libs = sorted(set(p.resolve(strict=True) for p in
        list((root / 'lib').glob('*.dylib')) +
        list((root / 'lib/gcc').glob('*/*/adalib/*.dylib'))))
    if any(not library.is_relative_to(root) for library in libs):
        raise ValueError('escaping library inventory')
    inventory = frozenset(str(library.relative_to(root)) for library in libs)
    if inventory != EXPECTED_LIBRARIES:
        raise ValueError(f'native Ada library inventory mismatch: missing={EXPECTED_LIBRARIES-inventory}, extra={inventory-EXPECTED_LIBRARIES}')
    proof = []
    for library in libs:
        if not library.is_file() or not library.is_relative_to(root):
            raise ValueError(f'escaping/non-file library: {library}')
        metadata = commands(library)
        rpaths = [value for command, value in metadata if command == 0x8000001C]
        bases = []
        for rpath in rpaths:
            if not (rpath == '@loader_path' or rpath.startswith('@loader_path/')):
                raise ValueError(f'unsupported RPATH: {library}: {rpath}')
            base = (library.parent / rpath.removeprefix('@loader_path').lstrip('/')).resolve()
            if not base.is_relative_to(root):
                raise ValueError(f'escaping RPATH: {library}: {rpath}')
            bases.append(base)
        for command, reference in metadata:
            if command not in (0xC, 0xD):
                continue
            if command == 0xC and reference in ('/usr/lib/libSystem.B.dylib', '/usr/lib/libiconv.2.dylib'):
                continue
            if not reference.startswith('@rpath/') or '/' in reference.removeprefix('@rpath/'):
                raise ValueError(f'unsupported dependency/ID: {library}: {reference}')
            if command == 0xD:
                if reference.removeprefix('@rpath/') != library.name:
                    raise ValueError(f'ID does not match its library: {library}: {reference}')
                proof.append({'library': str(library.relative_to(root)),
                              'command': hex(command), 'reference': reference,
                              'target': str(library.relative_to(root))})
                continue
            targets = set()
            for base in bases:
                candidate = base / reference.removeprefix('@rpath/')
                if candidate.exists():
                    target = candidate.resolve(strict=True)
                    if not target.is_file() or not target.is_relative_to(root):
                        raise ValueError(f'escaping/non-file target: {candidate}')
                    targets.add(target)
            if len(targets) != 1:
                raise ValueError(f'missing/ambiguous dependency: {library}: {reference}: {targets}')
            target = next(iter(targets))
            proof.append({'library': str(library.relative_to(root)),
                          'command': hex(command), 'reference': reference,
                          'target': str(target.relative_to(root))})
    return {'libraries': len(libs), 'resolved_paths': proof}


if __name__ == '__main__':
    print(json.dumps(validate(Path(sys.argv[1])), indent=2))
