defmodule ChangelogWeb.Plug.Conn do
  @moduledoc """
  General-purpose, connection-related functions available to controllers.
  """

  import Plug.Conn

  alias Plug.Crypto
  alias ChangelogWeb.Router

  @encryption_salt "8675309"
  @signing_salt "9035768"

  @doc """
  Extracts the user agent from a connection's headers
  """
  def get_agent(conn) do
    conn
    |> get_req_header("user-agent")
    |> List.first()
  end

  @doc """
  Extracts an encrypted cookie from the connection with the given key
  """
  def get_encrypted_cookie(conn, key) do
    cookie = conn.cookies[key]

    case decrypt_cookie(conn, cookie) do
      {:ok, decrypted} -> :erlang.binary_to_term(decrypted, [:safe])
      _else -> nil
    end
  end

  defp decrypt_cookie(_conn, nil), do: nil
  defp decrypt_cookie(conn, cookie) do
    Crypto.MessageEncryptor.decrypt(
      cookie,
      generate(conn, @signing_salt, key_opts()),
      generate(conn, @encryption_salt, key_opts()))
  end

  @doc """
  Adds an encrypted cookie to the connection with the given value
  """
  def put_encrypted_cookie(conn, key, value, opts \\ []) do
    opts = Keyword.put_new(opts, :max_age, 31_536_000) # one year

    encrypted = Crypto.MessageEncryptor.encrypt(
      :erlang.term_to_binary(value),
      generate(conn, @signing_salt, key_opts()),
      generate(conn, @encryption_salt, key_opts()))

    put_resp_cookie(conn, key, encrypted, opts)
  end

  defp key_opts do
    [iterations: 1000,
     length: 32,
     digest: :sha256,
     cache: Plug.Keys]
  end

  defp generate(conn, key, opts) do
    Crypto.KeyGenerator.generate(conn.secret_key_base, key, opts)
  end

  @doc """
  Extracts and returns the request referer, falling back to the root path
  """
  def referer_or_root_path(conn) do
    with {:ok, referer} <- extract_referer(conn),
         {:ok, path} <- extract_local_path(conn, referer)
    do
      path
    else
      _fail -> Router.Helpers.root_path(conn, :index)
    end
  end

  defp extract_referer(conn) do
    if referer = conn |> get_req_header("referer") |> List.last() do
      {:ok, referer}
    else
      {:error, "no referer header"}
    end
  end

  defp extract_local_path(conn, referer) do
    uri = URI.parse(referer)
    path = Map.get(uri, :path)

    cond do
      uri.host != conn.host -> {:error, "external referer"}
      String.starts_with?(path, "//") -> {:error, "invalid path"}
      true -> {:ok, path}
    end
  end
end
