# @akoutmos recommends the hex.pm image because it's maintained by the hex core team
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&ordering=last_updated&name=ubuntu-jammy
FROM hexpm/elixir:1.13.4-erlang-24.3.4.5-ubuntu-jammy-20220428

USER root

ARG FAIL_FAST_VERBOSE="set -ex"
ENV DEBIAN_FRONTEND=noninteractive
ARG PKG_INSTALL="apt-get install --yes"

# Use the terminal with 256 colors support
ENV TERM=xterm-256color

RUN echo "Pre-warm package manager cache..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; apt-get update

RUN echo "Install convert (imagemagick), required for image resizing..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; ${PKG_INSTALL} imagemagick \
    ; convert --version

RUN echo "Install curl..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; ${PKG_INSTALL} curl ca-certificates \
    ; curl --version

RUN echo "Install git..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; ${PKG_INSTALL} git \
    ; git --version

RUN echo "Install make..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; ${PKG_INSTALL} make \
    ; make --version

RUN echo "Install build-essential for gcc, required by cmark..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; ${PKG_INSTALL} build-essential \
    ; gcc --version

RUN echo "Install netcat for waiting on open ports..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; ${PKG_INSTALL} netcat

# https://nodejs.org/en/download/releases/
# https://github.com/nodejs/help/wiki/Installation#how-to-install-nodejs-via-binary-archive-on-linux
ENV NODEJS_VERSION=v14.20.0
ENV PATH=/usr/local/lib/nodejs/node-${NODEJS_VERSION}-linux-x64/bin:$PATH
RUN echo "Install node.js ${NODEJS_VERSION}..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; ${PKG_INSTALL} xz-utils ; xz --version \
    ; mkdir -p /usr/local/lib/nodejs \
    ; curl --silent --fail --location --output node-${NODEJS_VERSION}-linux-x64.tar.xz https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.xz \
    ; tar -xJvf node-${NODEJS_VERSION}-linux-x64.tar.xz -C /usr/local/lib/nodejs \
    ; node --version \
    ; rm node-${NODEJS_VERSION}-linux-x64.tar.xz

RUN echo "Install yarn..." \
    ; ${FAIL_FAST_VERBOSE} \
    ; npm install -g yarn \
    ; yarn --version

RUN mix local.rebar --force
RUN mix local.hex --force
