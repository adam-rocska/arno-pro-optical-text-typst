# Contributing

Run the full local quality-control suite before changing package behavior:

```sh
make check
```

`make check` requires `typst` and standard POSIX shell tools. It validates the
manifest, compiles all Typst fixtures under `tests/*/test.typ`, builds a
temporary local package under the `preview` namespace, compiles the public
example through that package import, and compiles every Typst code block in the
README.

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
