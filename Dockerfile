# --- BUILD STAGE ---
FROM oven/bun:1 AS builder

WORKDIR /app

# Disable prepare script (simple-git-hooks)
ENV SIMPLE_GIT_HOOKS=0
ENV BUN_ENV=production

# Copy all files
COPY . .

# Install dependencies without running prepare scripts
RUN bun install --no-save

# Build the executable binary
RUN bun build ./src/server.ts --compile --outfile copilot-api


# --- RUNTIME STAGE ---
FROM debian:bookworm-slim

WORKDIR /app

# Install certs
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy binary
COPY --from=builder /app/copilot-api /app/copilot-api

EXPOSE 4141

ENTRYPOINT ["/app/copilot-api"]
