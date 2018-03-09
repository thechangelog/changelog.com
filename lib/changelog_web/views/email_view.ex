defmodule ChangelogWeb.EmailView do
  use ChangelogWeb, :public_view

  alias Changelog.Faker
  alias ChangelogWeb.{AuthView, Endpoint, NewsItemView, PersonView}

  def auth_link_expires_in(person) do
    diff = Timex.diff(person.auth_token_expires_at, Timex.now, :duration)
    Timex.format_duration(diff, :humanized)
  end

  def greeting(person) do
    label = if Enum.member?(Faker.names, person.name) do
      "there"
    else
      PersonView.first_name(person)
    end

    "Hey #{label},"
  end
end
