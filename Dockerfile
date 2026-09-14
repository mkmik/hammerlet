ARG GO_VERSION=1.11.2

FROM golang:${GO_VERSION} AS builder

WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download

COPY ./ ./
RUN go build -o /app

# distroless with busybox
FROM gcr.io/distroless/base@sha256:0ebad3510af52aefe45045cc01b07564570be4feecf8d9f93d3a05d1b5f2f93b

COPY --from=builder /app /app

EXPOSE 8080

USER 1000:1000

ENTRYPOINT ["/app"]

