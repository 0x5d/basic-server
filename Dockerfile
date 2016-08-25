# Pull image from go, tag 1.6.3
FROM golang:1.6.3

# Set workdir
WORKDIR ~/go/src/github.com/castillobg/server

# Copy the source files into the container
COPY . .

# Compile the thing
RUN go build .

# "Expose" port 8080
EXPOSE 8080

# Run it when the container starts!
CMD ./server
