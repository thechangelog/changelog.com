defmodule ChangelogWeb.Plug.FlocOff do
  @moduledoc """
  Disables FLoC cohort calculation site-wide.
  See https://github.com/WICG/floc#opting-out-of-computation
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    put_resp_header(conn, "permissions-policy", "interest-cohort=()")
  end
end
