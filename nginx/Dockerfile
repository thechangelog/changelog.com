FROM thechangelog/legacy_assets AS legacy_assets
# https://hub.docker.com/_/nginx?tab=tags
# https://nginx.org/en/CHANGES
FROM nginx:1.15.12

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./conf.d /etc/nginx/conf.d
COPY --from=legacy_assets /var/www/wp-content /var/www/wp-content
