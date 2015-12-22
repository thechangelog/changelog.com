defmodule Changelog.Admin.PersonController do
  use Changelog.Web, :controller

  alias Changelog.Person

  def index(conn, _params) do
    people = Repo.all(Person)
    render conn, "index.html", people: people
  end
end
