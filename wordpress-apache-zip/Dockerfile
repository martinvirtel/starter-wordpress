FROM wordpress:php7.1
RUN apt-get update \
    && apt-get -y install libzip-dev \
    && pecl install zip \
    && apt-get clean \
    && docker-php-ext-enable zip \
    && a2enmod ssl \
    && cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/

