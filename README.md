PHP 8.4 / FPM container image
=============================================

PHP 8.4 FPM on the official `php:8.4-fpm-alpine3.24` image, for amd64 and arm64: `xpbl4/php84-fpm:alpine` (also `:latest`).
It is built like `xpbl4/php74-fpm:alpine`, so a project moves from one to the other by changing the version in its paths.

PHP extensions:
**apcu,
calendar,
curl,
exif,
ffi,
gd,
gettext,
imagick,
intl,
mbstring,
memcache,
mysqli,
opcache,
pcntl,
pdo_mysql,
shmop,
sockets,
sysvmsg, sysvsem, sysvshm,
xsl,
zip**

Extras:
**Cron (cronie), ImageMagick tools (`magick`, `convert`, `montage`, `mogrify`), bash, GNU sed, tzdata**

The paths are the ones of the Ubuntu packages:

* `/usr/sbin/php-fpm8.4`, `/usr/bin/php`, `/usr/bin/php8.4`, `/usr/sbin/cron`;
* ini files in `/etc/php/8.4/fpm/conf.d` (FPM) and `/etc/php/8.4/cli/conf.d` (CLI), extra pool files in `/etc/php/8.4/fpm/pool.d`;
* `www-data` with uid/gid 33, so the files written by the projects keep their owner;
* `php.ini` is `php.ini-production`.

*Crontab:* cronie reads `/etc/cron.d` files with a user column, like Debian cron.
`0 15 * * * root /app/daily-backup.sh >> /var/log/daily-backup.log 2>&1`

*Note on logging:* configure your application to stream logs into `php://stdout`. The startup script removes FPM's `[pool www] child xxx said into stderr` decoration.

musl has no locale data: `setlocale()` works, but localized month and day names come out in English.

Build for this machine:

```sh
docker build -t xpbl4/php84-fpm:alpine .
```

Publishing
=============================================

GitHub Actions (`.github/workflows/docker.yml`) lints the Dockerfile and builds the image for every pull request. A push to `master` publishes `xpbl4/php84-fpm:latest`, `:alpine` and `:alpine-<sha>` for amd64 and arm64 (arm64 is built under QEMU and takes longer).

The repository needs the `DOCKERHUB_TOKEN` secret (a Docker Hub access token) and the `DOCKERHUB_USERNAME` variable (defaults to `xpbl4`).
