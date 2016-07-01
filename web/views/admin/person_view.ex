defmodule Changelog.Admin.PersonView do
  use Changelog.Web, :view

  # import Scrivener.HTML

  def episode_count(person) do
    Changelog.Person.episode_count(person)
  end

  def post_count(person) do
    Changelog.Person.post_count(person)
  end
end
