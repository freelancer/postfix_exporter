# Build Stage
FROM golang:1.21-alpine AS builder
WORKDIR /src

# Install required packages for building
RUN apk add --no-cache build-base \
      libtool \
      automake \
      autoconf \
      elogind-dev

COPY go.mod go.sum ./
RUN go mod download
RUN go mod verify

COPY . .

ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH=amd64

RUN go test
RUN go build -o /bin/postfix_exporter -ldflags "-s -w" .

# Final Stage
FROM alpine:latest
EXPOSE 9154
WORKDIR /
COPY --from=builder /bin/postfix_exporter /bin/
ENTRYPOINT ["/bin/postfix_exporter"]
