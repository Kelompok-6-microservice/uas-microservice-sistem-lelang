FROM golang:1.21-alpine

WORKDIR /app

# Copy go.mod saja dulu
COPY go.mod ./

# Paksa download semua dependensi dan verifikasi
RUN go mod download && go mod verify

# Copy seluruh kode (termasuk main.go)
COPY . .

# Build dengan flag -o untuk memastikan binary tercipta
RUN go build -v -o main .

CMD ["./main"]