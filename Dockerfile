FROM golang:1.18-buster as builder
WORKDIR /app

COPY go.* ./
#Retrieve application dependencies
RUN go mod download

#Copy local code to the conatiner image
COPY invoke.go ./

#Build the binary
RUN go build -mod=readonly -v -o server

#Starting of multisttage builds
FROM debian:buster-slim
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

#Create and change to the app directory
WORKDIR /

#Copy the binary to the production image from the builder stage
COPY --from=builder /app/server /app/server
COPY script.sh ./

#Run the webservice on container startup
CMD ["/app/server"]

