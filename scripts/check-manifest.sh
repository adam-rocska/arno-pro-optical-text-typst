#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/common.sh
. "$script_dir/common.sh"

cd "$(repo_root)"

require_command awk
require_command git
require_command grep
require_command sort
require_command tr

step "Check package metadata"

name=$(manifest_value name)
version=$(manifest_value version)
entrypoint=$(manifest_value entrypoint)
description=$(manifest_value description)
compiler=$(manifest_value compiler)

[ -n "$name" ] || die "typst.toml is missing package.name"
[ -n "$version" ] || die "typst.toml is missing package.version"
[ -n "$entrypoint" ] || die "typst.toml is missing package.entrypoint"
[ -f "$entrypoint" ] || die "entrypoint does not exist: $entrypoint"

printf '%s\n' "$version" |
  grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z.-]+)?$' ||
  die "package.version is not a full semver: $version"

printf '%s\n' "$compiler" |
  grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' ||
  die "package.compiler is not a full version: $compiler"

[ "${#description}" -le 80 ] ||
  die "package.description should stay short for Typst Universe"

for key in authors license description repository keywords categories disciplines compiler; do
  grep -Eq "^[[:space:]]*${key}[[:space:]]*=" typst.toml ||
    die "typst.toml is missing package.$key"
done

expected_import="@preview/$name:$version"

grep -F "$expected_import" README.md >/dev/null ||
  die "README.md does not mention $expected_import"
grep -F "$expected_import" examples/basic.typ >/dev/null ||
  die "examples/basic.typ does not mention $expected_import"
grep -F "## $version" CHANGELOG.md >/dev/null ||
  die "CHANGELOG.md does not mention version $version"

stale_imports=$(
  grep -Rho '@preview/[A-Za-z0-9_.-]*:[0-9][^"`)[:space:]]*' \
    README.md examples tests src lib.typ 2>/dev/null |
    sort -u |
    grep -Fv "$expected_import" || true
)

[ -z "$stale_imports" ] ||
  die "found stale package import(s): $(printf '%s' "$stale_imports" | tr '\n' ' ')"

for excluded in \
  "/.github/" \
  "/.gitignore" \
  "/.typos.toml" \
  "/CHANGELOG.md" \
  "/CONTRIBUTING.md" \
  "/Makefile" \
  "/PUBLISHING.md" \
  "/SECURITY.md" \
  "/examples/" \
  "/scripts/" \
  "/tests/"
do
  grep -F "\"$excluded\"" typst.toml >/dev/null ||
    die "typst.toml exclude is missing $excluded"
done

generated=$(
  git ls-files |
    grep -E '(^|/)\.DS_Store$|\.(pdf|png|svg|html)$' || true
)

[ -z "$generated" ] ||
  die "generated artifact(s) are tracked: $(printf '%s' "$generated" | tr '\n' ' ')"

note "metadata is internally consistent"
