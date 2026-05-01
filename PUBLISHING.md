# Publishing

Before opening a package submission PR:

```sh
make check
```

Then run the official checker:

```sh
typst-package-check check
```

The manifest includes the public GitHub repository URL. Typst's package checker
validates optional URLs, so keep the repository public and reachable before
submitting to Typst Universe.

The published bundle is controlled by `exclude` in `typst.toml`. Keep
`README.md`, `LICENSE`, `lib.typ`, `src/`, and `typst.toml` in the bundle.
