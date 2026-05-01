#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/common.sh
. "$script_dir/common.sh"

cd "$(repo_root)"

require_command awk
require_command basename
require_command cat
require_command cp
require_command dirname
require_command find
require_command git
require_command mktemp
require_command mkdir
require_command sed
require_command sort
require_command typst

step "Smoke-test package import and README snippets"

name=$(manifest_value name)
version=$(manifest_value version)

tmp=$(make_temp_dir)
trap 'rm -rf "$tmp"' EXIT INT TERM

package_root="$tmp/packages/preview/$name/$version"
mkdir -p "$package_root"

git ls-files | while IFS= read -r file; do
  case "$file" in
    .github/*|.gitignore|.typos.toml|CHANGELOG.md|CONTRIBUTING.md|Makefile|examples/*|scripts/*|tests/*)
      continue
      ;;
  esac

  mkdir -p "$package_root/$(dirname "$file")"
  cp "$file" "$package_root/$file"
done

[ -f "$package_root/typst.toml" ] || die "package payload is missing typst.toml"
[ -f "$package_root/lib.typ" ] || die "package payload is missing lib.typ"

note "package payload"
find "$package_root" -type f | sort | sed "s#^$package_root/#    #"

note "examples/basic.typ through @preview import"
SOURCE_DATE_EPOCH=0 typst compile \
  --package-path "$tmp/packages" \
  examples/basic.typ \
  "$tmp/basic.pdf"

snippet_dir="$tmp/readme-snippets"
mkdir -p "$snippet_dir"

awk -v out="$snippet_dir" '
  /^```typst$/ {
    inside = 1
    count += 1
    file = sprintf("%s/readme-%02d.typ", out, count)
    next
  }

  /^```$/ && inside {
    inside = 0
    next
  }

  inside {
    print > file
  }

  END {
    print count > sprintf("%s/count", out)
  }
' README.md

count=$(cat "$snippet_dir/count")
count=${count:-0}
[ "$count" -gt 0 ] || die "README.md has no typst code snippets"

find "$snippet_dir" -type f -name 'readme-*.typ' | sort | while IFS= read -r snippet; do
  note "$(basename "$snippet")"
  SOURCE_DATE_EPOCH=0 typst compile \
    --package-path "$tmp/packages" \
    "$snippet" \
    "$snippet.pdf"
done

note "package import smoke test passed"
