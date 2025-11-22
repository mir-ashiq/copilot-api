# --- BUILD STAGE ---
FROM oven/bun:1 AS builder

WORKDIR /app

# Copy everything
COPY . .

# Install deps
RUN bun install --production

# Build the binary
RUN bun build ./src/server.ts --compile --outfile copilot-api


# --- RUNTIME STAGE ---
FROM debian:bookworm-slim

WORKDIR /app

# Install CA certificates
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates

# Copy binary from builder
COPY --from=builder /app/copilot-api /app/copilot-api

# Expose the default server port
EXPOSE 4141

# Run the binary
ENTRYPOINT ["/app/copilot-api"]
