# Multi-stage build: Build nginx from source, then create minimal runtime image
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy nginx source
WORKDIR /build
COPY . .

# Configure and build nginx
RUN auto/configure \
    --prefix=/usr/local/nginx \
    --with-http_ssl_module \
    --with-pcre \
    && make

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpcre3 \
    zlib1g \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy nginx binary and config from builder
COPY --from=builder /build/objs/nginx /usr/local/bin/nginx
COPY --from=builder /build/conf /usr/local/nginx/conf

# Create nginx user and log directories
RUN useradd -r -s /bin/false nginx && \
    mkdir -p /usr/local/nginx/logs && \
    chown -R nginx:nginx /usr/local/nginx

# Expose ports
EXPOSE 80 443

# Run nginx
ENTRYPOINT ["/usr/local/bin/nginx", "-g", "daemon off;"]
