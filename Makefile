CONTAINERTOOL := "docker"
DATE := $(shell date +%Y-%m-%d_%H%M%S)

all: help

.PHONY: help
help: Makefile
	@echo
	@echo " Available targets:"
	@sed -n 's/^##//p' $< | column -t -s ':' | sed -e 's/^/ /'
	@echo

## devenvs/ubuntu
.PHONY: devenvs/ubuntu
devenvs/ubuntu:
	$(CONTAINERTOOL) buildx build $(@) -t index.docker.io/johnstcn/dev-ubuntu:$(DATE) -t index.docker.io/johnstcn/dev-ubuntu:latest --platform linux/amd64,linux/arm64 --push
