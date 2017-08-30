defmodule ChangelogWeb.Admin.PersonView do
  use ChangelogWeb, :admin_view

  alias Changelog.Person
  alias ChangelogWeb.PersonView

  def avatar_url(person), do: PersonView.avatar_url(person)
  def episode_count(person), do: Person.episode_count(person)
  def list_of_links(person), do: PersonView.list_of_links(person)
  def post_count(person), do: Person.post_count(person)
end
