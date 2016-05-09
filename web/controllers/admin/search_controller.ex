defmodule Changelog.Admin.SearchController do
  use Changelog.Web, :controller

  def index(conn, %{"t" => "person", "q" => query}) do
    q = from p in Changelog.Person, where: ilike(p.name, ^"%#{query}%")
    render conn, "index.json", people: Repo.all(q)
  end

  def index(conn, %{"t" => "sponsor", "q" => query}) do
    q = from s in Changelog.Sponsor, where: ilike(s.name, ^"%#{query}%")
    render conn, "index.json", sponsors: Repo.all(q)
  end

  def index(conn, %{"t" => "channel", "q" => query}) do
    q = from c in Changelog.Channel, where: ilike(c.name, ^"%#{query}%")
    render conn, "index.json", channels: Repo.all(q)
  end
end
