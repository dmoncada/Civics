UV ?= uv
DIST := dist
PACKAGE := $(DIST)/current-officials.zip

.PHONY: test lint format check typecheck package clean

test:
	$(UV) run pytest

lint:
	$(UV) run ruff check .

format:
	$(UV) run ruff format .

check:
	$(UV) run ruff format --check .
	$(UV) run ruff check .

typecheck:
	$(UV) run ty check src

package:
	rm -rf $(DIST)/package $(PACKAGE)
	mkdir -p $(DIST)/package
	$(UV) export --locked --no-dev --format requirements-txt --output-file $(DIST)/requirements.txt
	$(UV) pip install --quiet --no-deps --target $(DIST)/package -r $(DIST)/requirements.txt
	cp -R src registry $(DIST)/package/
	cd $(DIST)/package && zip -qr ../current-officials.zip .

clean:
	rm -rf $(DIST)
