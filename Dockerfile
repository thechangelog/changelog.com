FROM elixir:1.3

# Postgres-client and Node installation:
RUN apt-get update && \
	curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
	apt-get install -y build-essential postgresql-client nodejs

# Project initialization:
RUN mkdir /code
WORKDIR /code
ADD . /code

RUN mix local.hex --force \
  && mix local.rebar --force \
  && mix deps.get \
  && mix deps.compile \
  && npm install
