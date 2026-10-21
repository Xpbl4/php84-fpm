# PHP 8.4 FPM on Alpine, built like xpbl4/php74-fpm:alpine: the Ubuntu paths, the ImageMagick tools and cron.
FROM php:8.4-fpm-alpine3.24

COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/

# The PHP modules of xpbl4/php74-fpm:alpine (the rest are built into the official image);
# bash and GNU sed run the startup script, cronie reads /etc/cron.d like Debian cron,
# imagemagick brings the convert/magick tools next to the imagick module.
# Then the Ubuntu paths that projects rely on: binaries, conf.d mounts, the FPM pool directory
# and www-data with uid/gid 33, which owns the projects' state files.
# PHP2Shell (CVE-2026-109618, CVE-2026-109619): the build fails on a base image older than PHP 8.4.27,
# and session upload progress, one of the attack paths, is off: no project uses it.
RUN php -r 'exit(version_compare(PHP_VERSION, "8.4.27", "<") ? 1 : 0);' \
    && install-php-extensions \
        apcu \
        calendar \
        exif \
        ffi \
        gd \
        gettext \
        imagick \
        intl \
        memcache \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        xsl \
        zip \
    && rm /usr/local/bin/install-php-extensions \
    && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && apk add --no-cache bash cronie imagemagick sed tzdata \
    && mkdir -p /etc/php/8.4/fpm/conf.d /etc/php/8.4/cli/conf.d /etc/php/8.4/fpm/pool.d \
    && ln -s /usr/sbin/crond /usr/sbin/cron \
    && ln -s /usr/local/bin/php /usr/bin/php \
    && ln -s /usr/local/bin/php /usr/bin/php8.4 \
    && printf 'include=/etc/php/8.4/fpm/pool.d/*.conf\n' >> /usr/local/etc/php-fpm.conf \
    && deluser www-data \
    && (delgroup www-data 2>/dev/null || true) \
    && user=$(awk -F: '$3 == 33 {print $1}' /etc/passwd) && { [ -z "$user" ] || deluser "$user"; } \
    && group=$(awk -F: '$3 == 33 {print $1}' /etc/group) && { [ -z "$group" ] || delgroup "$group"; } \
    && addgroup -g 33 -S www-data \
    && adduser -u 33 -S -D -H -h /var/www -s /sbin/nologin -G www-data www-data \
    && chown -R www-data:www-data /var/www \
    && printf 'session.upload_progress.enabled = 0\n' > "$PHP_INI_DIR/conf.d/zz-php2shell.ini"

ENV PHP_INI_SCAN_DIR=:/etc/php/8.4/cli/conf.d

COPY php-fpm8.4-alpine /usr/sbin/php-fpm8.4
COPY overrides.conf /etc/php/8.4/fpm/pool.d/z-overrides.conf
COPY php-fpm-startup /usr/bin/php-fpm

CMD ["/usr/bin/php-fpm"]

EXPOSE 9000
