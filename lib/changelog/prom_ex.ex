defmodule Changelog.PromEx do
  @moduledoc """
  Be sure to add the following to finish setting up PromEx:

  1. Update your configuration (config.exs, dev.exs, prod.exs, releases.exs, etc) to
  configure the necessary bit of PromEx. Be sure to check out `PromEx.Config` for
  more details regarding configuring PromEx:
  ```
    config :changelog, Changelog.PromEx,
      manual_metrics_start_delay: :no_delay,
      drop_metrics_groups: [],
      grafana: :disabled,
      metrics_server: :disabled
  ```

  2. Add this module to your application supervision tree:
  ```
  def start(_type, _args) do
    children = [
      ...

      Changelog.PromEx
    ]

    ...
  end
  ```

  3. Update your `endpoint.ex` file to expose your metrics (or configure a standalone
  server using the `:metrics_server` config options):
  ```
  defmodule ChangelogWeb.Endpoint do
    use Phoenix.Endpoint, otp_app: :changelog

    ...

    plug PromEx.Plug, prom_ex_module: Changelog.PromEx

    ...
  end
  ```
  """

  use PromEx, otp_app: :changelog

  @impl true
  def plugins do
    [
      # PromEx built in plugins
      {PromEx.Plugins.Application, otp_app: :changelog},
      PromEx.Plugins.Beam,
      {PromEx.Plugins.Phoenix, router: ChangelogWeb.Router},
      {PromEx.Plugins.Ecto, otp_app: :changelog, repos: [Changelog.Repo]}

      # Add your own PromEx metrics plugins
      # Changelog.Users.PromEx
    ]
  end

  @impl true
  def dashboards do
    [
      # PromEx built in dashboard definitions. Remove dashboards that you do not need
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "ecto.json"},
      {:prom_ex, "phoenix.json"}

      # Add your dashboard definitions here with the format: {:otp_app, "path_in_priv"}
      # {:changelog, "/grafana_dashboards/user_metrics.json"}
    ]
  end
end
