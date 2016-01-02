defmodule Changelog.Admin.SearchController do
  use Changelog.Web, :controller

  def index(conn, %{"t" => "person", "q" => query}) do
    q = from p in Changelog.Person, where: ilike(p.name, ^"%#{query}%")
    render conn, "index.json", people: Repo.all(q)
  end
end
