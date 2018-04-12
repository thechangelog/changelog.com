defmodule ChangelogWeb.Plug.Conn do
  import Plug.Conn

  @encryption_salt "8675309"
  @signing_salt "9035768"

  def put_encrypted_cookie(conn, key, value, opts \\ []) do
    opts = Keyword.put_new(opts, :max_age, 31_536_000) # one year

    encrypted = Plug.Crypto.MessageEncryptor.encrypt(
      :erlang.term_to_binary(value),
      generate(conn, @signing_salt, key_opts()),
      generate(conn, @encryption_salt, key_opts()))

    put_resp_cookie(conn, key, encrypted, opts)
  end

  def get_encrypted_cookie(conn, key) do
    case conn.cookies[key] do
      nil ->
        nil
      encrypted ->
        {:ok, decrypted} = Plug.Crypto.MessageEncryptor.decrypt(
          encrypted,
          generate(conn, @signing_salt, key_opts()),
          generate(conn, @encryption_salt, key_opts()))

        :erlang.binary_to_term(decrypted, [:safe])
    end
  end

  defp key_opts do
    [iterations: 1000,
     length: 32,
     digest: :sha256,
     cache: Plug.Keys]
  end

  defp generate(conn, key, opts) do
    Plug.Crypto.KeyGenerator.generate(conn.secret_key_base, key, opts)
  end
end
