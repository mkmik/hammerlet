ARG GO_VERSION=1.11.2

FROM golang:${GO_VERSION} AS builder

WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download

COPY ./ ./
RUN go build -o /app

# distroless with busybox
FROM gcr.io/distroless/base@sha256:9ec63deea5466b74effdf17186589a647fb1757856c15ae6eae7d878affa675d

COPY --from=builder /app /app

EXPOSE 8080

USER 1000:1000

ENTRYPOINT ["/app"]

