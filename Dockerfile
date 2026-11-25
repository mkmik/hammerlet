ARG GO_VERSION=1.11.2

FROM golang:${GO_VERSION} AS builder

WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download

COPY ./ ./
RUN go build -o /app

# distroless with busybox
FROM gcr.io/distroless/base@sha256:1eb7e763df3f75a0d0eab87368f04e1bc61ce268caf3f2cbae765fa8fd4fd3e8

COPY --from=builder /app /app

EXPOSE 8080

USER 1000:1000

ENTRYPOINT ["/app"]

