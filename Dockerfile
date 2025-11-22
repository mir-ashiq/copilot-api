# Multi-stage Dockerfile for typical Node.js apps (adjust node version if needed)
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package manifests and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and run build if present
COPY . .
# If you have a build step (e.g. TypeScript/webpack), ensure a script named "build" exists
RUN if [ -f package.json ] && npm run | grep -q ' build'; then npm run build; fi

# Remove dev deps (optional)
RUN npm prune --production || true

FROM node:18-alpine AS runner
WORKDIR /app

# Copy files from builder
COPY --from=builder /app /app

# Default port (override in run.claw.cloud)
ENV PORT=8080
EXPOSE 8080

# Prefer start script; fallback to node index.js
CMD ["sh", "-c", "npm run start --silent || node index.js"]
