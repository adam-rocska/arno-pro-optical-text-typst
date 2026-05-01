# Contributing

# Contributing

## Local Checks

Run the full local quality-control suite before changing package behavior:

```sh
make check
```

`make check` requires `typst` and standard POSIX shell tools. It validates the
manifest, compiles all Typst fixtures under `tests/*/test.typ`, builds a
temporary local package under the `preview` namespace, compiles the public
example through that package import, and compiles every Typst code block in the
README. When Arno Pro and `pdffonts` are available locally, it also audits the
embedded PDF font faces.

For CI parity, install the stricter optional tools and run:

```sh
make strict-check
```

Strict mode additionally requires:

- `typstyle` for Typst formatting checks.
- `shellcheck` for the POSIX shell quality-control scripts.
- `typst-package-check` for official Typst package validation.
- `tt` from Tytanic for the community Typst test runner.
- `typos` for spelling drift.

Tests should be compile-only Tytanic-compatible fixtures:

```text
tests/<case-name>/test.typ
```

Use absolute package-root imports inside tests, for example:

```typst
#import "/lib.typ": arno-pro-optical-font
```

## Pull Requests

Use short-lived branches and open pull requests into `master`. Keep changes
focused: implementation, tests, docs, and release metadata should be easy to
review together.

Before requesting review:

- Run `make check`.
- Update tests under `tests/*/test.typ` for behavior changes.
- Update README examples when public usage changes.
- Run `typst-package-check check` for release-facing metadata changes.

The repository prefers squash merges for pull requests. Merge commits are
disabled so `master` stays linear.

## Releases

For a release:

- Update `version` in `typst.toml`.
- Update package imports in docs and examples.
- Add a `CHANGELOG.md` entry.
- Run `make check`.
- Run `typst-package-check check`.
- Follow `PUBLISHING.md` for Typst Universe submission.
