UV ?= uv
DIST := dist
PACKAGE := $(DIST)/officials.zip

.PHONY: test lint format check typecheck package local-api local-api-debug clean

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
	docker run --rm --platform linux/amd64 --entrypoint pip \
		-v "$(CURDIR)/$(DIST):/asset" \
		public.ecr.aws/lambda/python:3.13 \
		install --no-cache-dir --requirement /asset/requirements.txt --target /asset/package
	cp -R src registry $(DIST)/package/
	cd $(DIST)/package && zip -qr ../officials.zip .

local-api:
	./scripts/start-api.sh

local-api-debug:
	SAM_DEBUG_PORT=5890 ./scripts/start-api.sh

clean:
	rm -rf $(DIST)
