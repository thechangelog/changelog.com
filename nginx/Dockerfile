FROM jwilder/nginx-proxy

COPY ./www/wp-content /var/www/wp-content
COPY ./vhost.d/default /etc/nginx/vhost.d/default
COPY ./conf.d/changelog.conf /etc/nginx/conf.d/changelog.conf
