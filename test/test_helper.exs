ExUnit.start

# Exclude all external tests from running
ExUnit.configure(exclude: [external: true])

Ecto.Adapters.SQL.Sandbox.mode(Changelog.Repo, :manual)
