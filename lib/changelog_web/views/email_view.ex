defmodule ChangelogWeb.EmailView do
  use ChangelogWeb, :public_view

  alias Changelog.Faker
  alias ChangelogWeb.{AuthView, Endpoint, NewsItemView, PersonView}

  def greeting(person) do
    label = if Enum.member?(Faker.names, person.name) do
      "there"
    else
      PersonView.first_name(person)
    end

    "Hey #{label},"
  end
end
