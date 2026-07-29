# Üretim imajı — statik binary + minimal runtime.
FROM golang:1.25.6-bookworm AS build

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server

FROM alpine:3.20

# tzdata şart: sipariş numarası time.Now().Year() üzerinden üretiliyor.
RUN apk add --no-cache ca-certificates tzdata wget
ENV TZ=Europe/Istanbul

WORKDIR /app
COPY --from=build /out/server /app/server
RUN mkdir -p /app/uploads

EXPOSE 8080
CMD ["/app/server"]
