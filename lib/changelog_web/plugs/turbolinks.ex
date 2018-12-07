# adapted from https://github.com/kagux/turbolinks_plug
# and https://gist.github.com/imranismail/5527b545f38b3be94579fc3b6d9f029e
defmodule ChangelogWeb.Plug.Turbolinks do
  import Plug.Conn

  @session_key "_turbolinks_location"
  @location_header "turbolinks-location"
  @referrer_header "turbolinks-referrer"

  def init(opts), do: opts

  def call(conn, _) do
    register_before_send(conn, &handle_redirect/1)
  end

  def handle_redirect(%Plug.Conn{status: s} = conn) when s in 301..302 do
    xhr = conn |> get_req_header("x-requested-with") |> List.first
    location = conn |> get_resp_header("location") |> hd
    referrer = conn |> get_req_header(@referrer_header)

    if xhr == "XMLHttpRequest" do
      redirect_with_turbolinks(conn, location)
    else
      store_location_in_session(conn, location, referrer)
    end
  end
  def handle_redirect(%Plug.Conn{status: s} = conn) when s in 200..299  do
    conn
    |> get_session(@session_key)
    |> set_location_header(conn)
  end
  def handle_redirect(conn), do: conn

  defp redirect_with_turbolinks(conn, location) do
    resp = turbolinks_resp(location, conn.method)
    conn
    |> put_resp_content_type(MIME.type("js"))
    |> resp(200, resp)
  end

  defp turbolinks_resp(to, "GET"), do: "Turbolinks.visit('#{to}');"
  defp turbolinks_resp(to, _) do
    """
    Turbolinks.clearCache();
    Turbolinks.visit('#{to}');
    """
  end

  defp store_location_in_session(conn, _location, []), do: conn
  defp store_location_in_session(conn, location, _referrer) do
    put_session(conn, @session_key, location)
  end

  defp set_location_header(nil, conn), do: conn
  defp set_location_header(location, conn) do
    conn
      |> put_resp_header(@location_header, location)
      |> delete_session(@session_key)
  end
end
