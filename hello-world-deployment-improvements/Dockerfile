# Stage 1: Build the Go Application
FROM golang:1.22.5-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy the app directory contents into the container at /app
COPY app /app

# Build the Go app
RUN go build -o hello-world .

# Stage 2: Create a lightweight image for running the application
# Use alpine for debugging purposes instead of scratch
FROM alpine

# Set the working directory inside the container
WORKDIR /root/

# Install bash and curl for debugging
RUN apk add --no-cache bash curl

# Copy the compiled binary from the builder stage to the current stage
COPY --from=builder /app/hello-world .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./hello-world"]
