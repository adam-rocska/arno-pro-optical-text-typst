# Publishing

Before opening a package submission PR:

```sh
make check
```

Then run the official checker:

```sh
typst-package-check check
```

The manifest intentionally omits `repository` until the public repository URL is
reachable. Typst's package checker validates optional URLs, so add it back only
after the repository exists and returns HTTP 200.

The published bundle is controlled by `exclude` in `typst.toml`. Keep
`README.md`, `LICENSE`, `lib.typ`, `src/`, and `typst.toml` in the bundle.

