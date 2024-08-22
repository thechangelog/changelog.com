defmodule ChangelogWeb do
  def static_paths, do: ~w(css fonts images js android-chrome apple-touch
    browserconfig favicon manifest mstile robots safari-pinned-tab)

  def controller do
    quote do
      use Phoenix.Controller, namespace: ChangelogWeb

      require Logger

      alias Changelog.{Policies, Repo}
      alias ChangelogWeb.Plug.{Authorize, RequireUser, RequireGuest}
      alias ChangelogWeb.Helpers.{SharedHelpers}

      import Ecto
      import Ecto.Query

      alias ChangelogWeb.Router.Helpers, as: Routes

      def log_request(conn, prefix \\ "REQUEST DETAILS") do
        details =
          conn
          |> Map.take([:params, :remote_ip, :req_headers])
          |> inspect()

        Logger.info("#{prefix}: #{conn.method} /#{conn.path_info} #{details}")
      end

      def send_to_sentry(event_name, info) when is_map(info) do
        if Mix.env() == :prod do
          Sentry.capture_message(event_name, extra: info)
        end
      end

      @doc """
      Allows param-based 'next' path to redirect with fallback when not specified
      """
      def redirect_next(conn, %{"next" => ""}, fallback), do: redirect(conn, to: fallback)

      def redirect_next(conn, %{"next" => "back"}, fallback),
        do: redirect(conn, to: ChangelogWeb.Plug.Conn.get_local_referer(conn) || fallback)

      def redirect_next(conn, %{"next" => next}, _fallback), do: redirect(conn, to: next)
      def redirect_next(conn, _params, fallback), do: redirect(conn, to: fallback)

      @doc """
      Useful in combination with `redirect_next` when schema changes (usually slug)
      affect the edit path being redirected to
      """
      def replace_next_edit_path(params = %{"next" => "edit"}, path),
        do: Map.put(params, "next", path)

      def replace_next_edit_path(params, _path), do: params

      defp is_admin?(user = %Changelog.Person{}), do: user.admin
      defp is_admin?(_), do: false

      unquote(verified_routes())
    end
  end

  def admin_view do
    quote do
      use Phoenix.View, root: "lib/changelog_web/templates", namespace: ChangelogWeb
      use Phoenix.HTML

      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      alias ChangelogWeb.Router.Helpers, as: Routes
      alias ChangelogWeb.Helpers.{AdminHelpers, SharedHelpers}
      alias Changelog.Policies
      alias ChangelogWeb.TimeView

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ChangelogWeb.LayoutView, :live}

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import HelloWeb.CoreComponents
      import HelloWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS
    end
  end

  def public_view do
    quote do
      use Phoenix.View,
        root: "lib/changelog_web/templates",
        namespace: ChangelogWeb,
        pattern: "**/*"

      use Phoenix.HTML

      import Phoenix.Component
      import Phoenix.Controller,
        only: [current_url: 1, get_flash: 1, get_flash: 2, view_module: 1]

      def escaped(string) do
        string |> html_escape() |> safe_to_string()
      end

      alias ChangelogWeb.Router.Helpers, as: Routes
      alias ChangelogWeb.Helpers.{PublicHelpers, SharedHelpers}
      alias Changelog.Policies
      alias ChangelogWeb.{SharedView, TimeView}

      unquote(verified_routes())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Changelog.Repo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ChangelogWeb.Endpoint,
        router: ChangelogWeb.Router,
        statics: ChangelogWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
