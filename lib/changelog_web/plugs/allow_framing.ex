defmodule ChangelogWeb.Plug.AllowFraming do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn = %{request_path: path}, _opts) do
    if String.ends_with?(path, "embed") do
      conn
      # Remove old x-frame-options header if present (for backwards compatibility)
      |> delete_resp_header("x-frame-options")
      # Update CSP to allow embedding from any origin
      |> update_csp_for_embedding()
    else
      conn
    end
  end

  defp update_csp_for_embedding(conn) do
    # Phoenix 1.8+ uses CSP frame-ancestors instead of x-frame-options
    # Remove frame-ancestors restriction to allow embedding
    case get_resp_header(conn, "content-security-policy") do
      [csp | _] ->
        # Remove frame-ancestors directive to allow embedding from anywhere
        new_csp = Regex.replace(~r/frame-ancestors [^;]+;?\s*/, csp, "")
        put_resp_header(conn, "content-security-policy", new_csp)

      [] ->
        conn
    end
  end
end
