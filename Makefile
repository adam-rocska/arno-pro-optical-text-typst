.PHONY: check strict-check test smoke manifest font-audit fmt-check shellcheck package-check tytanic typos

check:
	./scripts/check.sh

strict-check:
	STRICT=1 ./scripts/check.sh

test:
	./scripts/run-typst-tests.sh

smoke:
	./scripts/package-smoke.sh

manifest:
	./scripts/check-manifest.sh

font-audit:
	./scripts/font-audit.sh

fmt-check:
	typstyle --check lib.typ src tests examples

shellcheck:
	shellcheck scripts/*.sh

package-check:
	typst-package-check check

tytanic:
	tt run --no-fail-fast

typos:
	typos
