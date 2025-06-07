# Use Ubuntu as base image
FROM ubuntu:22.04
LABEL maintainer="devuser@example.com"

# Install SSL-related packages and nginx
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directory for certificates
RUN mkdir -p /etc/ssl/private

# Copy SSL certificate and key
COPY server.crt /etc/ssl/certs/
COPY server.key /etc/ssl/private/

# Set proper permissions
RUN chmod 644 /etc/ssl/certs/server.crt && \
    chmod 600 /etc/ssl/private/server.key

# Copy nginx configuration and website content
COPY nginx-ssl.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/

# Update CA certificates
RUN update-ca-certificates

# Expose HTTPS port
EXPOSE 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
