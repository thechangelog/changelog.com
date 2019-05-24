FROM thechangelog/runtime:2018-11-23.103218

RUN mkdir /app
COPY . /app
WORKDIR /app

ENV MIX_ENV=prod
ENV TERM=xterm

EXPOSE 4000

CMD make report-deploy ; mix do ecto.create, ecto.migrate, phx.server
