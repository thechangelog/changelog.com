defmodule Changelog.Admin.PersonView do
  use Changelog.Web, :admin_view

  def avatar_url(person), do: Changelog.PersonView.avatar_url(person)
  def episode_count(person), do: Changelog.Person.episode_count(person)
  def list_of_links(person), do: Changelog.PersonView.list_of_links(person)
  def post_count(person), do: Changelog.Person.post_count(person)
end
