defmodule ChangelogWeb.Plug.AdminLayoutPlug do
  def init(opts), do: opts

  def call(conn, _opts) do
    Phoenix.Controller.put_layout(conn, {ChangelogWeb.LayoutView, :admin})
  end
end
