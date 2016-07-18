defmodule Changelog.PageController do
  use Changelog.Web, :controller

  def about(conn, _params) do
    render(conn, :about)
  end

  def contact(conn, _params) do
    render(conn, :contact)
  end

  def films(conn, _params) do
    render(conn, :films)
  end

  def home(conn, _params) do
    render(conn, :home)
  end

  def membership(conn, _params) do
    render(conn, :membership)
  end

  def nightly(conn, _params) do
    render(conn, :nightly)
  end

  def partnership(conn, _params) do
    render(conn, :partnership)
  end

  def sponsorship(conn, _params) do
    render(conn, :sponsorship)
  end

  def store(conn, _params) do
    render(conn, :store)
  end

  def team(conn, _params) do
    render(conn, :team)
  end

  def weekly(conn, _params) do
    render(conn, :weekly)
  end
end
