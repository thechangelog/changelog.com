FROM thechangelog/legacy_assets AS legacy_assets
FROM thechangelog/runtime:2022-09-21T23.19.21Z

RUN mkdir /app
ARG APP_FROM_PATH=.
COPY ${APP_FROM_PATH} /app
WORKDIR /app
RUN echo "Ensure deps are present & OK..." \
    ; ls -lahd deps/*
RUN echo "Ensure prod bytecode is present & OK..." \
    ; ls -lahd _build/prod/lib/*/ebin
RUN echo "Ensure prod static assets are present & OK..." \
    ; ls -lah priv/static/cache_manifest.json

COPY --from=legacy_assets /var/www/wp-content /app/priv/wp-content

ENV MIX_ENV=prod
ENV TERM=xterm

# Used by PromEx for annotations
ARG GIT_AUTHOR
ENV GIT_AUTHOR=${GIT_AUTHOR}
ARG GIT_SHA
ENV GIT_SHA=${GIT_SHA}
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}

ARG BUILD_URL
ENV BUILD_URL=${BUILD_URL}
# Used by various tooling to report the identity & origin of this build
RUN echo "$GIT_SHA" > priv/static/version.txt \
    ; echo "$GIT_AUTHOR" > COMMIT_USER \
    ; echo "$BUILD_URL" > priv/static/build.txt

EXPOSE 4000

CMD make on-app-start; mix changelog.static.upload; mix do ecto.create, ecto.migrate, phx.server
