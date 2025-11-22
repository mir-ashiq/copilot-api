# Multi-stage Dockerfile for a Bun-based project
# Uses a lightweight Node base and installs Bun via the official installer script.
# This keeps the image reproducible without depending on an external prebuilt bun image.
FROM node:18-alpine AS builder

# Install dependencies required to run the bun installer
RUN apk add --no-cache curl bash

# Install Bun (official installer)
RUN curl -fsSL https://bun.sh/install | bash

# Make bun available on PATH
ENV BUN_INSTALL_DIR=/root/.bun
ENV PATH="$BUN_INSTALL_DIR/bin:$PATH"

WORKDIR /app

# Copy package manifest and (if present) bun.lockb to allow reproducible installs
COPY package.json package-lock.json* bun.lockb* ./

# Install dependencies with bun
# --production=false so devDependencies are available for build if needed
RUN bun install --no-checks --no-save || bun install

# Copy the rest of the source
COPY . .

# Run the build if there is a build script
RUN if bun run | grep -q ' build'; then bun run build; fi

# Final runtime image
FROM node:18-alpine AS runner
RUN apk add --no-cache curl bash
RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL_DIR=/root/.bun
ENV PATH="$BUN_INSTALL_DIR/bin:$PATH"

WORKDIR /app

# Copy built app and node_modules from builder
COPY --from=builder /app /app

# Use PORT environment variable (platform will set this)
ENV PORT=8080
EXPOSE 8080

# Run using the package.json start script (the repo's start uses bun)
CMD ["bun", "run", "start"]
