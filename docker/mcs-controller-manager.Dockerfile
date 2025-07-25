# Build the manager binary
FROM mcr.microsoft.com/oss/go/microsoft/golang:1.24.4 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# the go command will load packages from the vendor directory instead of downloading modules from their sources into
# the module cache and using packages those downloaded copies.
COPY vendor/ vendor/

# Copy the go source
COPY cmd/mcs-controller-manager/main.go main.go
COPY api/ api/
COPY pkg/ pkg/

# Build
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GO111MODULE=on go build -o mcs-controller-manager main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /workspace/mcs-controller-manager .
USER 65532:65532

ENTRYPOINT ["/mcs-controller-manager"]
