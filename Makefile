SHELL=/bin/bash -o pipefail

GO_EXEC = go1.15.8

EXECUTABLES = docker ${GO_EXEC}
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

export GO111MODULE := on
export PATH := .bin:${PATH}

.PHONY: deps
deps:
ifneq ("$(shell base64 Makefile))","$(shell cat .bin/.lock)")
		${GO_EXEC} build -o .bin/go-acc github.com/ory/go-acc
		${GO_EXEC} build -o .bin/goreturns github.com/sqs/goreturns
		${GO_EXEC} build -o .bin/listx github.com/ory/x/tools/listx
		${GO_EXEC} build -o .bin/mockgen github.com/golang/mock/mockgen
		${GO_EXEC} build -o .bin/swagger github.com/go-swagger/go-swagger/cmd/swagger
		${GO_EXEC} build -o .bin/goimports golang.org/x/tools/cmd/goimports
		${GO_EXEC} build -o .bin/ory github.com/ory/cli
		${GO_EXEC} build -o .bin/packr github.com/gobuffalo/packr/packr
		${GO_EXEC} build -o .bin/go-bindata github.com/go-bindata/go-bindata/go-bindata
		echo "v0" > .bin/.lock
		echo "$$(base64 Makefile)" > .bin/.lock
endif

.PHONY: format
format: deps
		goreturns -w -local github.com/ory $$(listx .)

.PHONY: install-stable
install-stable: deps
		KETO_LATEST=$$(git describe --abbrev=0 --tags)
		git checkout $$KETO_LATEST
		packr
		GO111MODULE=on ${GO_EXEC} install \
				-ldflags "-X github.com/ory/keto/cmd.Version=$$KETO_LATEST -X github.com/ory/keto/cmd.Date=`TZ=UTC date -u '+%Y-%m-%dT%H:%M:%SZ'` -X github.com/ory/keto/cmd.Commit=`git rev-parse HEAD`" \
				.
		packr clean
		git checkout master

.PHONY: install
install: deps
		packr
		GO111MODULE=on ${GO_EXEC} install .
		packr clean

# Generates the SDKs
.PHONY: sdk
sdk: deps
		swagger generate spec -m -o ./.schema/api.swagger.json -x internal/httpclient
		ory dev swagger sanitize ./.schema/api.swagger.json
		swagger flatten --with-flatten=remove-unused -o ./.schema/api.swagger.json ./.schema/api.swagger.json
		swagger validate ./.schema/api.swagger.json
		rm -rf internal/httpclient
		mkdir -p internal/httpclient
		swagger generate client -f ./.schema/api.swagger.json -t internal/httpclient -A Ory_Keto
		make format

.PHONY: docker
docker: deps
		packr
		GO111MODULE=on GOOS=linux GOARCH=amd64 ${GO_EXEC} build
		docker build -t oryd/keto:latest .
		rm keto
		packr clean
