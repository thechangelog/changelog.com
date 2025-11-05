defmodule ChangelogWeb.Plug.AdminLayoutPlug do
  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> Phoenix.Controller.put_root_layout(false)
    |> Phoenix.Controller.put_layout({ChangelogWeb.LayoutView, :admin})
  end
end
