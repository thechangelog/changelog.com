defmodule ChangelogWeb.Plug.Conn do
  @moduledoc """
  General-purpose, connection-related functions available to controllers.
  """

  import Plug.Conn
  alias Plug.Crypto

  @encryption_salt "8675309"
  @signing_salt "9035768"

  def get_agent(conn) do
    conn
    |> get_req_header("user-agent")
    |> List.first()
  end

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
end
