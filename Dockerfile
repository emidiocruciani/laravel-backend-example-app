FROM php:8.1-alpine AS base

WORKDIR /app

# Set UTC timezone
RUN echo "UTC" > /etc/timezone

# Install needed packages
RUN apk add zip unzip curl bash su-exec supervisor

# Setup bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing php
RUN apk add php81 \
    php81-common \
    php81-fpm \
    php81-pdo \
    php81-opcache \
    php81-zip \
    php81-phar \
    php81-iconv \
    php81-cli \
    php81-curl \
    php81-openssl \
    php81-mbstring \
    php81-tokenizer \
    php81-fileinfo \
    php81-json \
    php81-xml \
    php81-xmlwriter \
    php81-simplexml \
    php81-dom \
    php81-pdo_pgsql \
    php81-tokenizer \
    php81-pecl-redis

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Enable php extensions
RUN apk add --virtual .pgsql-deps \
	postgresql-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apk del .pgsql-deps

# Configure supervisor (base)
RUN mkdir -p /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor



FROM base AS development

# Development variables
ARG WWWUSER=1000
ARG WWWGROUP=1000

ENV WWWUSER=$WWWUSER
ENV WWWGROUP=$WWWGROUP

# Add local development user
RUN addgroup -S -g $WWWGROUP laravel
RUN adduser -D -S -s /bin/bash -G laravel -u $WWWUSER laravel

# Configure supervisor (development)
COPY ./docker/dev/app/supervisord.ini /etc/supervisor.d/supervisord.ini

# Configure php
COPY ./docker/dev/app/php.ini /etc/php81/php.ini

# Load entrypoint script
COPY ./docker/dev/app/start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

# Expose port
EXPOSE 8000

# Set container entrypoint
CMD ["start-container"]



FROM base AS production

# Copy all (see .dockerignore for exceptions)
COPY ./source /app/
RUN chown -R www-data:www-data /app

# Build vendor directory
RUN composer install --no-dev

# Configure supervisor (production)
COPY ./docker/prod/app/supervisord.ini /etc/supervisor.d/supervisord.ini

# Configure php
COPY ./docker/prod/app/php.ini /etc/php81/php.ini

# Load entrypoint script
COPY ./docker/prod/app/start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

# Expose port
EXPOSE 8000

# Set on-start command
CMD ["start-container"]
