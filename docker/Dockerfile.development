FROM thechangelog/runtime

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix do deps.get, compile
RUN cd assets && yarn install

CMD mix do deps.get, compile, ecto.create, ecto.migrate, phx.server
