#! /bin/bash


# Install composer as of https://getcomposer.org/download/
#

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

#  correct ...
# 

cd /var/www/html/wp-content/plugins/firebase-notifications
php /var/www/html/composer.phar install

# Installing dependencies from lock file (including require-dev)
# Verifying lock file contents can be installed on current platform.
# Nothing to install, update or remove
# Generating autoload files



cd /var/www/html/wp-content/plugins/user-meta-pro
php /var/www/html/composer.phar install

# Installing dependencies from lock file (including require-dev)
# Verifying lock file contents can be installed on current platform.
# Package operations: 1 install, 0 updates, 0 removals 
#   - Installing curl/curl (1.9.3): Extracting archive
#   Generating autoload files

mv helpers/captcha.php /tmp
   

cd /var/www/html/wp-content/plugins/wp-sentry-integration/build
php /var/www/html/composer.phar install


# Installing dependencies from lock file (including require-dev)
# Verifying lock file contents can be installed on current platform.
# Package operations: 0 installs, 4 updates, 0 removals
#   - Upgrading guzzlehttp/psr7 (1.7.0 => 1.8.1): Extracting archive
#   - Upgrading symfony/options-resolver (v4.4.19 => v4.4.20): Extracting archive
#   - Upgrading guzzlehttp/promises (1.4.0 => 1.4.1): Extracting archive
#   - Upgrading sentry/sentry (3.1.5 => 3.2.1): Extracting archive
# Generating optimized autoload files
# 7 packages you are using are looking for funding.
# Use the `composer fund` command to find out more!

