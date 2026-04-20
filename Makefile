SWIFT := "/usr/bin/swift"

.PHONY: fmt
fmt: swift-fmt

.PHONY: check
check: swift-fmt-check

.PHONY: swift-fmt
SWIFT_SRC = $(shell find . -type f -name '*.swift' -not -path "*/.*" -not -path "*.pb.swift" -not -path "*.grpc.swift" -not -path "*/checkouts/*")
swift-fmt:
	@echo Applying the standard code formatting...
	@$(SWIFT) format --recursive --configuration .swift-format -i $(SWIFT_SRC)

swift-fmt-check:
	@echo Applying the standard code formatting...
	@$(SWIFT) format lint --recursive --strict --configuration .swift-format-nolint $(SWIFT_SRC)

.PHONY: pre-commit
pre-commit:
	cp scripts/pre-commit.fmt .git/hooks
	touch .git/hooks/pre-commit
	cat .git/hooks/pre-commit | grep -v 'hooks/pre-commit\.fmt' > /tmp/pre-commit.new || true
	echo 'PRECOMMIT_NOFMT=$${PRECOMMIT_NOFMT} $$(git rev-parse --show-toplevel)/.git/hooks/pre-commit.fmt' >> /tmp/pre-commit.new
	mv /tmp/pre-commit.new .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
