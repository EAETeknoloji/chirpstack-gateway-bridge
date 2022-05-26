.PHONY: build clean test package serve run-compose-test
VERSION := $(shell git describe --always |sed -e "s/^v//")

build:
	@echo "Compiling source"
	@mkdir -p build
	go build $(GO_EXTRA_BUILD_ARGS) -ldflags "-s -w -X main.version=$(VERSION)" -o build/chirpstack-gateway-bridge cmd/chirpstack-gateway-bridge/main.go

clean:
	@echo "Cleaning up workspace"
	@rm -rf build
	@rm -rf dist

test:
	@echo "Running tests"
	@rm -f coverage.out
	@golint ./...
	@go vet ./...
	@go test -cover -v -coverprofile coverage.out -p 1 ./...

dist:
	@goreleaser
	mkdir -p dist/upload/deb
	mv dist/*.deb dist/upload/deb

snapshot:
	@goreleaser --snapshot

dev-requirements:
	go install golang.org/x/lint/golint
	go install github.com/goreleaser/goreleaser
	go install github.com/goreleaser/nfpm

# shortcuts for development

serve: build
	./build/chirpstack-gateway-bridge

run-compose-test:
	docker-compose run --rm chirpstack-gateway-bridge make test
