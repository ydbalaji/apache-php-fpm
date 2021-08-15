FROM ubuntu:latest

LABEL maintainer="Balaji Y D"

RUN apt-get update
RUN apt-get -y upgrade

ENV DEBIAN_FRONTEND noninteractive

# Edit sources.list to add to install libapache2-mod-fastcgi
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse \ndeb http://archive.ubuntu.com/ubuntu trusty-updates multiverse \ndeb http://security.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list

# Add apt repository.
RUN apt-get update ; \
    apt-get install -y \
    software-properties-common ; \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

## Install apache, curl and lynx-cur are for debugging the container.
RUN apt-get update ; \
    apt-get install -y \
    apache2 \
    openssl \
    libapache2-mod-fcgid \
    libapache2-mod-fastcgi \
    vim \
    ssl-cert \
    ca-certificates \
    curl \
    git \
    wget \
    zip \
    cron \
    supervisor 

## Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

## Enabling apache  variables
RUN a2enmod ssl \
    && a2dismod mpm_prefork \
    && a2dismod mpm_event \
    && a2enmod mpm_worker \
    && a2enmod actions \
    && a2enmod fastcgi \
    && a2enmod http2 \
    && a2enmod headers \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_fcgi \
    && a2enmod proxy_http \
    && a2enmod alias \
    && a2enmod vhost_alias \
    && a2enmod remoteip

## Install php7.3
RUN apt-get update ; \
    apt-get install -y \
    php7.3 \
    php7.3-apcu \
    php7.3-bcmath \
    php7.3-calendar \
    php7.3-cli \
    php7.3-common \
    php7.3-curl \
    php7.3-exif \
    php7.3-fpm \
    php7.3-gd  \
    php7.3-imagick \
    php7.3-imap \
    php7.3-intl \
    php7.3-json \
    php7.3-ldap \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-mysqli \
    php7.3-opcache \
    php7.3-pdo \
    php7.3-pgsql \
    php7.3-redis \
    php7.3-soap \
    php7.3-sqlite3 \
    php7.3-sqlite \
    php7.3-xml \
    php7.3-xsl \
    php7.3-zip  \
    libapache2-mod-php7.3 \
    php-zmq \
	php-memcached \
	php-igbinary \
    ## Install Mysql client
    mysql-client
    

## Activate PHP 7.4 Cli
RUN update-alternatives --set php /usr/bin/php7.3

## Installing Composer from dockerimage
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Copy the dockerentry point
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

## Copy Apache Config files
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
# RUN a2ensite 000-default.conf

## Copy Supervisor file in to conatianer
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## Copy the Apache Config file for Php-fpm
# COPY php7.3-fpm.conf /etc/apache2/conf-available/php7.3-fpm.conf

## Copy the index.php to /var/www/html
COPY index.php /var/www/html/index.php

RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/7.4/fpm/php-fpm.conf

RUN mkdir -p /var/log/php-fpm
RUN mkdir -p /var/run/php
RUN a2enconf php7.3-fpm

## Ports 80 and 443
EXPOSE 80
EXPOSE 443

# ADD app /var/www/html
WORKDIR "/var/www/html"

# By default, simply start apache and PHP by supervisord in entrypoint.
ENTRYPOINT [ "/docker-entrypoint.sh" ]