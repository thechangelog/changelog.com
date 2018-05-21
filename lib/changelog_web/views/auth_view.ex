defmodule ChangelogWeb.AuthView do
  use ChangelogWeb, :public_view

  alias Changelog.Person

  def auth_path(conn, person) do
    sign_in_path(conn, :create, person.auth_token)
  end

  def auth_url(conn, person) do
    sign_in_url(conn, :create, person.auth_token)
  end
end
