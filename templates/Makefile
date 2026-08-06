.PHONY: build test test-race test-integration lint vuln audit cover fmt tidy check

build:
	go build ./...

test:
	go test ./... -count=1

test-race:
	go test ./... -count=1 -race

test-integration:
	go test ./... -count=1 -tags=integration

lint:
	golangci-lint run

vuln:
	govulncheck ./...

audit: lint vuln
	@command -v gitleaks >/dev/null && gitleaks detect --no-banner || echo "gitleaks nao instalado (opcional)"

cover:
	go test ./... -count=1 -coverprofile=cover.out && go tool cover -func=cover.out | tail -1

fmt:
	gofumpt -w . 2>/dev/null || gofmt -w .
	goimports -w . 2>/dev/null || true

tidy:
	go mod tidy

check: build lint test
