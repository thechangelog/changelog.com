defmodule Changelog.AuthView do
  use Changelog.Web, :view
  alias Changelog.Person

  def auth_path(person) do
    {:ok, encoded} = Person.encoded_auth(person)
    "/in/#{encoded}"
  end
end
