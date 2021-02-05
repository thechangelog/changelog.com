defmodule Changelog.PromEx do
  use PromEx, otp_app: :changelog

  @impl true
  def plugins do
    [
      # PromEx built in plugins
      {PromEx.Plugins.Application, otp_app: :changelog},
      PromEx.Plugins.Beam,
      {PromEx.Plugins.Phoenix, router: ChangelogWeb.Router},
      {PromEx.Plugins.Ecto, otp_app: :changelog, repos: [Changelog.Repo]},
      PromEx.Plugins.Oban

      # Add your own PromEx metrics plugins
      # Changelog.Users.PromEx
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "Prometheus"
    ]
  end

  @impl true
  def dashboards do
    [
      # PromEx built in dashboard definitions. Remove dashboards that you do not need
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "ecto.json"},
      {:prom_ex, "phoenix.json"},

      # Add your dashboard definitions here with the format: {:otp_app, "path_in_priv"}
      {:changelog, "/grafana_dashboards/app.json"},
      {:changelog, "/grafana_dashboards/erlang.json"},
      {:changelog, "/grafana_dashboards/ecto.json"},
      {:changelog, "/grafana_dashboards/phoenix.json"}
    ]
  end
end
