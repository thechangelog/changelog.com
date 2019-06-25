# https://hub.docker.com/r/docker/compose/tags
ARG DOCKER_COMPOSE_VERSION
FROM docker/compose:$DOCKER_COMPOSE_VERSION

RUN apk add git && git version
RUN apk add make && make --version
RUN apk add ncurses && tput -V
RUN apk add bash && bash --version
ENV SHELL=/bin/bash
ENV TERM=xterm

ENV DOCKER=/usr/local/bin/docker
ENV COMPOSE=/usr/local/bin/docker-compose

ARG GIT_REPOSITORY=https://github.com/thechangelog/changelog.com
ENV GIT_REPOSITORY=$GIT_REPOSITORY
ARG GIT_BRANCH=master
ENV GIT_BRANCH=$GIT_BRANCH

ARG UPDATE_SERVICE_EVERY_N_SECONDS=60
ENV UPDATE_SERVICE_EVERY_N_SECONDS=$UPDATE_SERVICE_EVERY_N_SECONDS
ARG DOCKER_SERVICE_NAME=2019_app
ENV DOCKER_SERVICE_NAME=$DOCKER_SERVICE_NAME
ARG DOCKER_SERVICE_IMAGE=thechangelog/changelog.com
ENV DOCKER_SERVICE_IMAGE=$DOCKER_SERVICE_IMAGE

COPY aliases.sh /etc/profile.d/aliases.sh

VOLUME /app
WORKDIR /app

COPY deploy_docker_stack update_service_continuously /usr/local/bin/
RUN cd /usr/local/bin && chmod +x deploy_docker_stack update_service_continuously

ENTRYPOINT ["/bin/bash", "--login", "-c"]
CMD ["deploy_docker_stack"]
