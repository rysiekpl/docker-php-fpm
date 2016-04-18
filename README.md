# Docker PHP FPM

Highy configurable PHP FPM container.

PHP app/pool name, username and group (along with uid and gid), app source directory, interface/port/socket PHP listens on are configurable via environment variables; as are any additional packages to be installed upon container startup.

The startup script makes sure to signal `php-fpm` when logfiles are deleted or moved. This can be used in conjunction with `logrotate`, with the caveat that the logrotated logfiles have to be physically *moved or deleted* for the startup script to notice. Hence, it is adviseable to *not* use `copy` or `copytruncate` [logrotate options](http://linux.die.net/man/8/logrotate)

There is also no need to use the `create` option for the error log file (configured via `PHP_ERROR_LOG`), as `php-fpm` will re-create that file automagically.

Licensed under [GNU Affero GPL](https://gnu.org/licenses/agpl.html).

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
    -e PHP_ERROR_LOG="/var/log/myapp/error.log" \
    --build-arg INSTALL_PACKAGES="php5-intl php5-ming" \
    -v "/path/to/code/:/opt/myapp/:ro" \
    docker-php-rpm
```

And with `docker-compose` ([v.2](https://docs.docker.com/compose/compose-file/#version-2)):

```
php.myapp:
    build: 
        context: docker-php-fpm/
        args:
            INSTALL_PACKAGES: "php5-intl php5-ming"
    environment:
        PHP_APP_NAME:     "myapp"
        PHP_APP_USER:     "myapp_user"
        PHP_APP_GROUP:    "myapp_group"
        PHP_APP_LISTEN:   "/var/run/php/myapp.socket"
        PGP_APP_DIR:      "/opt/myapp/"
        PHP_ERROR_LOG:    "/var/log/myapp/error.log"
    volumes:
        - ""/path/to/code/:/opt/myapp/:ro""
```

## [Build-time variables](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg)

 - `INSTALL_PACKAGES`

List of packages to `apt-get install` during build, to be used as an alternative to forking this image or using it in the Dockerfile `FROM` clause.

This is the preferred way of installing additional packages (compare: `INSTALL_PACKAGES` environment variable).

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

 - `INSTALL_PACKAGES` (**deprecated** -- use `INSTALL_PACKAGES` build arg instead)

List of packages to `apt-get install` during startup, to be used as an alternative to forking this image or using it in the Dockerfile `FROM` clause.

This packages *will be installed each time the docker container is recreated*, so this will have a negative effect on container startup time!

 - `PHP_ACCESS_LOG` (default: `"/dev/null"`)
 - `PHP_ERROR_LOG` (default: `"/dev/null"`)
 - `PHP_SLOW_LOG` (default: `"/dev/null"`)

Access, [error](http://php.net/manual/en/errorfunc.configuration.php#ini.error-log), and slowlog locations, accordingly. By default all are set to `/dev/null`.

 - `PHP_PID_FILE` (default: `"/var/run/php5-fpm.pid"`)

The `php-fpm` pidfile location.

**Caveat:** if `/etc/php5/fpm/pool.d/$PHP_APP_NAME.conf` config file is found (say, volume-mounted into the container), all $PHP_* vars are ignored. Some, however (notably: `PHP_PID_FILE` and `PHP_ERROR_LOG`) are not set in that file, and need to be set in `/etc/php5/fpm/php-fpm.conf` file.