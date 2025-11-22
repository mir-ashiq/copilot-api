# --- BUILD STAGE ---
FROM oven/bun:1 AS builder

WORKDIR /app

# Copy project files
COPY . .

# Install production dependencies
RUN bun install --production

# Build the executable binary
RUN bun build ./src/server.ts --compile --outfile copilot-api


# --- RUNTIME STAGE ---
FROM debian:bookworm-slim

WORKDIR /app

# Install CA certificates
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy binary from builder
COPY --from=builder /app/copilot-api /app/copilot-api

# Expose default API port
EXPOSE 4141

# Start Copilot API
ENTRYPOINT ["/app/copilot-api"]
