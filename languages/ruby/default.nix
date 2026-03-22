# Ruby toolchain multi-version support
#
# Provides multiple Ruby interpreter versions.
#
# Usage:
#   rubyVersions = import ./languages/ruby { inherit pkgs; };
#   # Then use rubyVersions.default, rubyVersions.ruby_3_2, etc.

{ pkgs }:
{
  # Default Ruby version
  default = pkgs.ruby;
  latest = pkgs.ruby;

  # Specific versions (note: older versions get EOL quickly)
  ruby_3_3 = pkgs.ruby_3_3 or pkgs.ruby;
  ruby_3_4 = pkgs.ruby_3_4 or pkgs.ruby;

  # Development tools
  bundler = pkgs.bundler;
  rake = pkgs.rake or null;
  ruby-lsp = pkgs.ruby-lsp or null;

  # Convenient alias
  ruby = pkgs.ruby;
}
