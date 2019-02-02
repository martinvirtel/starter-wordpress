FROM wordpress:4.9-php7.1-apache
RUN apt-get update \
    && apt-get -y install libzip-dev \
    && pecl install zip \
    && apt-get clean \
    && docker-php-ext-enable zip 
