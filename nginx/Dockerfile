FROM thechangelog/legacy_assets AS legacy_assets
FROM jwilder/nginx-proxy

COPY ./vhost.d/default /etc/nginx/vhost.d/default
COPY ./conf.d/changelog.conf /etc/nginx/conf.d/changelog.conf
COPY --from=legacy_assets /var/www/wp-content /var/www/wp-content
