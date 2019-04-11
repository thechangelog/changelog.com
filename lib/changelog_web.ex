defmodule ChangelogWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: ChangelogWeb

      alias Changelog.{Policies, Repo}
      alias ChangelogWeb.Plug.{Authorize, RequireUser, RequireGuest}

      import Ecto
      import Ecto.Query

      import ChangelogWeb.Router.Helpers
      import ChangelogWeb.Plug.Conn

      plug ChangelogWeb.Plug.ResponseCache
      import ChangelogWeb.Plug.ResponseCache, only: [cache_public: 1, cache_public: 2]

      @doc """
      Allows param-based 'next' path to redirect with fallback when not specified
      """
      def redirect_next(conn, %{"next" => ""}, fallback), do: redirect(conn, to: fallback)
      def redirect_next(conn, %{"next" => next}, _fallback), do: redirect(conn, to: next)
      def redirect_next(conn, _params, fallback), do: redirect(conn, to: fallback)

      @doc """
      Useful in combination with `redirect_next` when schema changes (usually slug)
      affect the edit path being redirected to
      """
      def replace_next_edit_path(params = %{"next" => "edit"}, path), do: Map.put(params, "next", path)
      def replace_next_edit_path(params, _path), do: params

      defp is_admin?(user = %Changelog.Person{}), do: user.admin
      defp is_admin?(_), do: false
    end
  end

  def admin_view do
    quote do
      use Phoenix.View, root: "lib/changelog_web/templates", namespace: ChangelogWeb
      use Phoenix.HTML
      import Phoenix.Controller, only: [get_flash: 1,get_flash: 2, view_module: 1]
      import Scrivener.HTML
      import ChangelogWeb.Router.Helpers
      import ChangelogWeb.Helpers.{AdminHelpers, SharedHelpers}
      alias Changelog.Policies
      alias ChangelogWeb.TimeView
    end
  end

  def public_view do
    quote do
      use Phoenix.View, root: "lib/changelog_web/templates", namespace: ChangelogWeb, pattern: "**/*"
      use Phoenix.HTML
      import Phoenix.Controller, only: [current_url: 1, get_flash: 1,get_flash: 2, view_module: 1]
      import ChangelogWeb.Router.Helpers
      import ChangelogWeb.Helpers.{PublicHelpers, SharedHelpers}
      alias Changelog.Policies
      alias ChangelogWeb.{SharedView, TimeView}
    end
  end

  def router do
    quote do
      use Phoenix.Router
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

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
