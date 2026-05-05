#!/bin/sh

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

step() {
  printf '\n==> %s\n' "$*" >&2
}

note() {
  printf '    %s\n' "$*" >&2
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

manifest_value() {
  awk -F '"' -v key="$1" '
    $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
      print $2
      exit
    }
  ' typst.toml
}

make_temp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/arnoptical.XXXXXX"
}

strict_enabled() {
  [ "${STRICT:-0}" = "1" ] || [ "${STRICT:-}" = "true" ]
}

