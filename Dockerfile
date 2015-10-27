FROM debian:jessie

MAINTAINER Michał "rysiek" Woźniak <rysiek@hackerspace.pl>
# based on https://github.com/leoditommaso/docker_php-fpm/blob/master/Dockerfile
# by Leandro Di Tommaso <leandro.ditommaso@mikroways.net>

# Packages to install on the container.
# FIXME: check if everything here is actually needed
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y upgrade && apt-get install -y \
  php5-fpm php5-curl php5-gd php5-imagick php5-imap php5-json php5-mcrypt php5-mysql \
  php5-xcache php5-xmlrpc php5-xsl php5-geoip --no-install-recommends && apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Define environment variables.
# Change the following to rename your app or change the user and group the app will run
# with. I don't recommend modifying the user and group but there's no problem in changing
# the app name.
ENV PHP_APP_NAME    "www"
ENV PHP_APP_USER    "www-data"
ENV PHP_APP_GROUP   "www-data"
ENV PHP_APP_DIR     "/opt/php/"
ENV PHP_LISTEN      "[::]:9000"
ENV PHP_ACCESS_LOG  "/dev/null"
ENV PHP_ERROR_LOG   "/dev/null"
ENV PHP_SLOW_LOG    "/dev/null"
ENV PHP_PID_FILE    "/var/run/php5-fpm.pid"

# clean up the pool config directory
RUN rm -rf /etc/php5/fpm/pool.d/*

# default pool config file
COPY pool.conf /etc/php5/fpm/pool.d/pool.conf

# startup wrapper
COPY start.sh /var/lib/php5/start

# make sure the PHP dir exists
# TODO: ONBUILD?
RUN mkdir $PHP_APP_DIR && chown $APP_USER:$APP_GROUP $PHP_APP_DIR

# volumes
VOLUME ["/var/run/php-fpm", "/var/log/php-fpm", "/etc/php5", "/opt/php/"]

# expose
EXPOSE 9000

CMD ["/var/lib/php5/start"]
ENTRYPOINT ["/bin/bash"]