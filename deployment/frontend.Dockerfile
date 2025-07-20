FROM node:18-alpine as builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Production stage
FROM node:18-alpine as production

WORKDIR /app

# Install serve globally
RUN npm install -g serve@14.2.4

# Create non-root user
# RUN addgroup -g 1000 cravyn && adduser -u 1000 -G cravyn -s /bin/sh -D cravyn

# Copy built app
COPY --from=builder /app/build ./build
# RUN chown -R cravyn:cravyn /app

# USER cravyn

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start command
CMD ["serve", "-s", "build", "-l", "3000"]