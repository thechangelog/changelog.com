FROM elixir:1.3

ENV LANG=C.UTF-8 PATH="./node_modules/.bin:$PATH"

# Postgres-client and Node installation:
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y apt-utils build-essential postgresql-client nodejs \
    && gpg --keyserver pgpkeys.mit.edu --recv-key 5C808C2B65558117 \
    && gpg -a --export 5C808C2B65558117 | apt-key add - \
    && echo "deb http://www.deb-multimedia.org jessie main" > /etc/apt/sources.list.d/deb-multimedia.list \
    && apt-get update \
    && apt-get install -y deb-multimedia-keyring ffmpeg \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Project initialization:
RUN mkdir /code
WORKDIR /code
ADD . /code

RUN mix local.hex --force \
  && mix deps.get \
  && mix deps.compile \
  && npm install
