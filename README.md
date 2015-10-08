# Docker PHP FPM

Highy configurable PHP FPM container.

## Usage

This image is meant to be used with `nginx` or any other webserver that supports FastCGI

Usage example with pure `docker`:

```
docker build --tag docker-php-fpm docker-php-fpm/

docker run \
    -e PHP_APP_NAME=myapp \
    -e PHP_APP_USER=myapp_user \
    -e PHP_APP_GROUP=myapp_group \
    -e PHP_APP_LISTEN=/var/run/php/myapp.socket \
    -e PHP_APP_DIR=/opt/myapp/
    -e INSTALL_PACKAGES="php5-intl php5-ming" \
    -v "/path/to/code/:/opt/myapp/:ro" \
    docker-php-rpm
```

And with `docker-compose`:

```
php.myapp:
    build: docker-php-fpm/
    environment:
        PHP_APP_NAME:     "myapp"
        PHP_APP_USER:     "myapp_user"
        PHP_APP_GROUP:    "myapp_group"
        PHP_APP_LISTEN:   "/var/run/php/myapp.socket"
        PGP_APP_DIR:      "/opt/myapp/"
        INSTALL_PACKAGES: "php5-intl php5-ming"
    volumes:
        - ""/path/to/code/:/opt/myapp/:ro""
```

## Environment variables

This container is configurable with the following environment variables. However, if a config file is explicitly volume-mounted, it is up to the user to make sure that the user and group combination used in that config file is compatible with `PHP_*` envvars!

 - `PHP_APP_NAME` (default: `"www"`)

Name of the application, used in pool config file name, PHP pool name, etc.

 - `PHP_APP_USER` (default: `"www-data"`)
 - `PHP_APP_UID`

The username to run the `php5-fpm` process as. If the user does not exist, it will be created (with `PHP_APP_UID` as uid, if provided), and will be put in `PHP_APP_GROUP` group.

If both `PHP_APP_USER` and `PHP_APP_UID` are provided, and there is an existing user with `PHP_APP_USER`, but with a different uid, the startup script will fail with an error.

 - `PHP_APP_GROUP` (default: `"www-data"`)
 - `PHP_APP_GID`
 
The group to run the `php5-fpm` process as. If the group does not exist, it will be created (with `PHP_APP_GID` as uid, if provided).

If both `PHP_APP_GROUP` and `PHP_APP_GID` are provided, and there is an existing user with `PHP_APP_GROUP`, but with a different uid, the startup script will fail with an error.

 - `PHP_APP_DIR` (default: `"/opt/php/"`)

Directory with code to run.

 - `PHP_APP_LISTEN` (default: `"[::]:9000"`)

What interface to listen on -- compatible with the `listen` directive of the `php.ini` config file: can be either an `IP:PORT` combination, only a `PORT`, or a `/path/to/unix/socket`.

 - `INSTALL_PACKAGES`

List of packages to `apt-get install` during startup, to be used as an alternative to forking this image or using it in the Dockerfile `FROM` clause.

This packages *will be installed each time the docker container is recreated*, so this will have a negative effect on container startup time!