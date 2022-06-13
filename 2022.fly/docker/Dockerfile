# https://hub.docker.com/_/docker
FROM docker:20.10.17

RUN apk add bash ip6tables pigz sysstat procps lsof

COPY etc/docker/daemon.json /etc/docker/daemon.json

COPY ./entrypoint ./entrypoint
COPY ./docker-entrypoint.d/* ./docker-entrypoint.d/

ENV DOCKER_TMPDIR=/data/docker/tmp

ENTRYPOINT ["./entrypoint"]

CMD ["dockerd", "-p", "/var/run/docker.pid", "--tls=false"]
