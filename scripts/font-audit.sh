#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/common.sh
. "$script_dir/common.sh"

cd "$(repo_root)"

require_command grep
require_command mktemp
require_command typst

step "Audit rendered Arno Pro font faces"

if ! command -v pdffonts >/dev/null 2>&1; then
  note "skipping font audit; pdffonts is not installed"
  exit 0
fi

missing_fonts=$(
  for family in \
    "Arno Pro" \
    "Arno Pro Caption" \
    "Arno Pro Display" \
    "Arno Pro Smbd SmText" \
    "Arno Pro SmText" \
    "Arno Pro Subhead"
  do
    if ! typst fonts | grep -Fx "$family" >/dev/null; then
      printf '%s\n' "$family"
    fi
  done
)

if [ -n "$missing_fonts" ]; then
  note "skipping font audit; missing local font families:"
  printf '%s\n' "$missing_fonts" | while IFS= read -r family; do
    note "$family"
  done
  exit 0
fi

tmp=$(make_temp_dir)
trap 'rm -rf "$tmp"' EXIT INT TERM

show_pdf="$tmp/show-text-rule.pdf"
fallback_pdf="$tmp/fallback-font-list.pdf"

SOURCE_DATE_EPOCH=0 typst compile --root . \
  tests/show-text-rule/test.typ \
  "$show_pdf"

show_fonts=$(pdffonts "$show_pdf")

for face in \
  ArnoPro-Regular \
  ArnoPro-Caption \
  ArnoPro-SmText \
  ArnoPro-Subhead \
  ArnoPro-Display \
  ArnoPro-SmbdSmText
do
  printf '%s\n' "$show_fonts" | grep -F "$face" >/dev/null ||
    die "show-rule fixture did not embed $face"
done

SOURCE_DATE_EPOCH=0 typst compile --root . \
  tests/fallback-font-list/test.typ \
  "$fallback_pdf"

fallback_fonts=$(pdffonts "$fallback_pdf")

printf '%s\n' "$fallback_fonts" | grep -F "ArnoPro-Caption" >/dev/null ||
  die "fallback font-list fixture did not embed ArnoPro-Caption"

note "rendered font audit passed"

