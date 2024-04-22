defmodule Changelog.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      ChangelogWeb.Endpoint,
      {Phoenix.PubSub, [name: Changelog.PubSub, adapter: Phoenix.PubSub.PG2]},
      Changelog.Repo,
      con_cache_child_spec(
        :app_cache,
        ttl_check_interval: :timer.seconds(1),
        global_ttl: :timer.seconds(60)
      ),
      {Oban, oban_config()}
    ]

    # Only attach the telemetry logger when we aren't in an IEx shell
    unless Code.ensure_loaded?(IEx) && IEx.started?() do
      Oban.Telemetry.attach_default_logger(:info)

      Changelog.ObanReporter.attach()
    end

    :opentelemetry_cowboy.setup()
    OpentelemetryEcto.setup([:changelog, :repo])
    OpentelemetryOban.setup(trace: [:jobs])
    OpentelemetryPhoenix.setup(adapter: :cowboy2)

    Supervisor.start_link(children, strategy: :one_for_one, name: Changelog.Supervisor)
  end

  defp oban_config do
    Application.get_env(:changelog, Oban)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChangelogWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp con_cache_child_spec(name, opts) do
    Supervisor.child_spec(
      {
        ConCache,
        Keyword.put(opts, :name, name)
      },
      id: {ConCache, name}
    )
  end
end
