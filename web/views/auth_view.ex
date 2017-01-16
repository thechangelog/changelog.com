defmodule Changelog.AuthView do
  use Changelog.Web, :public_view

  alias Changelog.Person

  def auth_path(conn, person) do
    {:ok, encoded} = Person.encoded_auth(person)
    sign_in_path(conn, :create, encoded)
  end

  def auth_url(conn, person) do
    {:ok, encoded} = Person.encoded_auth(person)
    sign_in_url(conn, :create, encoded)
  end
end
