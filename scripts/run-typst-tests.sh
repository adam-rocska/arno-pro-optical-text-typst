#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/common.sh
. "$script_dir/common.sh"

cd "$(repo_root)"

require_command find
require_command mktemp
require_command sed
require_command sort
require_command typst

step "Compile Typst test fixtures"

tmp=$(make_temp_dir)
trap 'rm -rf "$tmp"' EXIT INT TERM

tests=$(find tests -type f -name test.typ | sort)
[ -n "$tests" ] || die "no tests/*/test.typ fixtures found"

printf '%s\n' "$tests" | while IFS= read -r test_file; do
  test_name=$(printf '%s' "$test_file" | sed 's#[/.]#_#g')
  note "$test_file"
  SOURCE_DATE_EPOCH=0 typst compile --root . \
    "$test_file" \
    "$tmp/$test_name.pdf"
done

note "all Typst fixtures compiled"
