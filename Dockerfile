FROM golang:1.25-alpine AS modules
WORKDIR /modules
COPY go.mod go.sum ./
RUN go mod download

FROM golang:1.25-alpine AS builder
COPY --from=modules /go/pkg /go/pkg
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o bin/api ./cmd/api

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/bin/api /api
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["/api"]
