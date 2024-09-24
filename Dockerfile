ARG GO_VERSION=1.11.2

FROM golang:${GO_VERSION} AS builder

WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download

COPY ./ ./
RUN go build -o /app

# distroless with busybox
FROM gcr.io/distroless/base@sha256:6ae5fe659f28c6afe9cc2903aebc78a5c6ad3aaa3d9d0369760ac6aaea2529c8

COPY --from=builder /app /app

EXPOSE 8080

USER 1000:1000

ENTRYPOINT ["/app"]

