PROJ="poke"
ORG_PATH="github.com/coreos"
REPO_PATH="$(ORG_PATH)/$(PROJ)"
export PATH := $(PWD)/bin:$(PATH)

export GOBIN=$(PWD)/bin
export GO15VENDOREXPERIMENT=1

GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)

COMMIT=$(shell git rev-parse HEAD)

# check if the current commit has a matching tag
TAG=$(shell git describe --exact-match --abbrev=0 --tags $(COMMIT) 2> /dev/null || true)

ifeq ($(TAG),)
	VERSION=$(TAG)
else
	VERSION=$(COMMIT)
endif


build: bin/poke

bin/poke: FORCE
	@go install $(REPO_PATH)/cmd/poke

test:
	@go test $(shell go list ./... | grep -v '/vendor/')

testrace:
	@go test --race $(shell go list ./... | grep -v '/vendor/')

vet:
	@go vet $(shell go list ./... | grep -v '/vendor/')

fmt:
	@go fmt $(shell go list ./... | grep -v '/vendor/')

lint:
	@for package in $(shell go list ./... | grep -v '/vendor/' | grep -v 'api/apipb'); do \
      golint $$package; \
	done

clean:
	@rm bin/*

testall: testrace vet fmt lint

FORCE:

.PHONY: test testrace vet fmt lint testall