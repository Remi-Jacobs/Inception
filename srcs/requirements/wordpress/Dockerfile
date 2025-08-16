FROM alpine:3.22

# Accept DB credentials from docker-compose or .env
ARG DB_NAME
ARG DB_USER
ARG DB_PASS

# Set environment variables for runtime access
ENV DB_NAME=${DB_NAME}
ENV DB_USER=${DB_USER}
ENV DB_PASS=${DB_PASS}

RUN apk update && apk add --no-cache \
    php84 \
    php84-fpm \
    php84-mysqli \
    php84-json \
    php84-dom \
    php84-exif \
    php84-fileinfo \
    php84-openssl \
    php84-curl \
    php84-zlib \
    php84-xml \
    php84-phar \
    php84-mbstring \
    php84-zip \
    php84-session \
    curl \
    wget \
    unzip \
    tar \
    bash \
    mysql-client

# Set up PHP-FPM config
RUN mkdir -p /run/php && \
    sed -i 's|^listen = .*|listen = 9000|' /etc/php84/php-fpm.d/www.conf && \
    sed -i 's|^;clear_env = no|clear_env = no|' /etc/php84/php-fpm.d/www.conf

# Download WordPress
WORKDIR /var/www
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz --strip-components=1 && \
    rm wordpress.tar.gz

# Copy startup script for wp-config
COPY requirements/wordpress/conf/wp-config-create.sh /wp-config-create.sh
RUN chmod +x /wp-config-create.sh

# Fix permissions
RUN chown -R nobody:nobody /var/www && \
    chmod -R 755 /var/www

EXPOSE 9000

# Use a shell to first run wp-config creation, then start PHP-FPM
CMD ["/bin/sh", "-c", "/wp-config-create.sh && exec /usr/sbin/php-fpm84 -F"]
