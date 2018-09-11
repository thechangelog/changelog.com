defmodule Changelog.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(ChangelogWeb.Endpoint, []),
      # Start the Ecto repository
      worker(Changelog.Repo, []),
      # Here you could define other workers and supervisors as children
      worker(UA.Parser, []),
      # worker(Changelog.Worker, [arg1, arg2, arg3]),
      worker(ConCache, [
        [
          name: :app_cache,
          ttl_check_interval: :timer.seconds(1),
          global_ttl: :timer.seconds(60)
        ]
      ]),
      worker(Changelog.Scheduler, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Changelog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChangelogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
