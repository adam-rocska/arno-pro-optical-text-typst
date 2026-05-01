#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/common.sh
. "$script_dir/common.sh"

cd "$(repo_root)"

require_command git
require_command typst

"$script_dir/check-manifest.sh"
"$script_dir/run-typst-tests.sh"
"$script_dir/package-smoke.sh"
"$script_dir/font-audit.sh"

run_optional() {
  tool=$1
  label=$2
  shift 2

  if command -v "$tool" >/dev/null 2>&1; then
    step "$label"
    "$@"
  elif strict_enabled; then
    die "STRICT=1 requires $tool"
  else
    note "skipping $label; install $tool or run STRICT=1 in CI"
  fi
}

run_optional typstyle "Check Typst formatting" \
  typstyle --check lib.typ src tests examples

run_optional shellcheck "Check shell scripts" \
  shellcheck scripts/*.sh

run_optional typst-package-check "Run official Typst package checks" \
  typst-package-check check

run_optional tt "Run Tytanic test suite" \
  tt run --no-fail-fast

run_optional typos "Run spelling guard" \
  typos

step "Quality control passed"
