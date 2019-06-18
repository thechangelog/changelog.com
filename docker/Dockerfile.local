FROM thechangelog/changelog.com

# Modify the latest production image to test changes locally, in the local stack
# before promoting them into Dockerfile.production

# It's safest to copy files which have dependencies already met in the current production
# If you find yourself needing to test changes which require a new mix dep, or asset recompilation, consider using `gmake contrib` instead
COPY ./lib/changelog_web/endpoint.ex /app/lib/changelog_web/endpoint.ex
COPY ./lib/changelog_web/plugs/health_check.ex /app/lib/changelog_web/plugs/health_check.ex
COPY ./config /app/config

RUN date -u +'%Y-%m-%dT%H:%M:%SZ' > /app/priv/static/version.txt

COPY ./Makefile /app/Makefile

CMD elixir --sname changelog -S mix do ecto.create, ecto.migrate, phx.server
