ARG GO_VERSION=1.11.2

FROM golang:${GO_VERSION} AS builder

WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download

COPY ./ ./
RUN go build -o /app

# distroless with busybox
FROM gcr.io/distroless/base@sha256:075a33d9c49026ca7ee72738b4c4a1caea55d0f44227356e46a611a211050e20

COPY --from=builder /app /app

EXPOSE 8080

USER 1000:1000

ENTRYPOINT ["/app"]

