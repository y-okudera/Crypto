.PHONY: help
help: ## Show this usage
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: bootstrap
bootstrap: ## Install tools
	mint bootstrap

.PHONY: project
project: ## Setup Xcode project and workspace
	mint run mockolo mockolo --enable-args-history -s DataSource/ -d DataSourceTests/Mock/Generated/Mock.swift -i DataSource

.PHONY: open
open: ## Open Xcode project
	open Crypto.xcodeproj
