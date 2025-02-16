FROM golang:1.23-alpine AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download && \
    go install github.com/a-h/templ/cmd/templ@latest

COPY . .

RUN templ generate && \
    CGO_ENABLED=0 GOOS=linux go build ./cmd/web/...


FROM alpine:latest AS release
WORKDIR /app

COPY --from=build /app/web /app/web

EXPOSE 3000

RUN addgroup -S nonroot && adduser -S nonroot -G nonroot

USER nonroot:nonroot

CMD ["/app/web"]
