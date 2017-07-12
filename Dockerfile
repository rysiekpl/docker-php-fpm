FROM debian:stretch

MAINTAINER Michał "rysiek" Woźniak <rysiek@hackerspace.pl>
# based on https://github.com/leoditommaso/docker_php-fpm/blob/master/Dockerfile
# by Leandro Di Tommaso <leandro.ditommaso@mikroways.net>

# Packages to install on the container.
# FIXME: check if everything here is actually needed
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
        php7.0-fpm \
        php7.0-curl \
        php7.0-gd \
        php7.0-imagick \
        php7.0-imap \
        php7.0-json \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-xmlrpc \
        php7.0-xsl \
        php7.0-geoip \
        inotify-tools && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Define environment variables.
# Change the following to rename your app or change the user and group the app will run
# with. I don't recommend modifying the user and group but there's no problem in changing
# the app name.
ENV PHP_APP_NAME="www" \
    PHP_APP_USER="www-data" \
    PHP_APP_GROUP="www-data" \
    PHP_APP_DIR="/opt/php/" \
    PHP_LISTEN="[::]:9000" \
    PHP_ACCESS_LOG="/dev/null" \
    PHP_ERROR_LOG="/dev/null" \
    PHP_SLOW_LOG="/dev/null" \
    PHP_PID_FILE="/var/run/php7.0-fpm.pid"

# we might need to install some packages, but doing this in the entrypoint doesn't make any sense
ARG INSTALL_PACKAGES=
RUN if [ "$INSTALL_PACKAGES" != "" ]; then \
        export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y \
            $INSTALL_PACKAGES \
            --no-install-recommends && \
        rm -rf /var/lib/apt/lists/* ; \
    fi
    
# clean up the pool config directory
RUN rm -rf /etc/php/7.0/fpm/pool.d/*

# default pool config file
COPY pool.conf /etc/php/7.0/fpm/pool.d/pool.conf

# startup wrapper
COPY start.sh /var/lib/php7.0/start
RUN chmod a+x /var/lib/php7.0/start

# make sure the PHP dir exists
# TODO: ONBUILD?
RUN mkdir $PHP_APP_DIR && chown $PHP_APP_USER:$PHP_APP_GROUP $PHP_APP_DIR
ONBUILD COPY . $PHP_APP_DIR
ONBUILD RUN chown $PHP_APP_USER:$PHP_APP_GROUP $PHP_APP_DIR

# volumes
VOLUME ["/var/run/php-fpm", "/var/log/php-fpm", "/etc/php/7.0", "/opt/php/"]

# expose

EXPOSE 9000

ENTRYPOINT ["/var/lib/php7.0/start"]
CMD ["/usr/sbin/php-fpm7.0", "-F", "--fpm-config", "/etc/php/7.0/fpm/php-fpm.conf"]