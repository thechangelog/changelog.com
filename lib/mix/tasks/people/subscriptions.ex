defmodule Mix.Tasks.Changelog.Subscriptions do
  use Mix.Task

  alias Changelog.{Faker, Person, Podcast, Repo, Subscription}
  alias ChangelogWeb.PersonView
  alias NimbleCSV.RFC4180, as: CSV

  @shortdoc "Imports people and subscriptions from CM csv exports"

  def run([import_file]) do
    Mix.Task.run "app.start"

    podcast =
      import_file
      |> Path.basename()
      |> String.replace_trailing(".csv", "")
      |> Podcast.get_by_slug!()

    import_file
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.each(fn([name, email, _]) ->
      email
      |> find_or_insert_person(name)
      |> subscribe_if_not_already(podcast)
    end)
  end

  defp subscribe_if_not_already(person, podcast) do
    if !PersonView.is_subscribed(person, podcast) do
      Subscription.subscribe(person, podcast, "you subscribed way back in the day (pre-launch)")
    end
  end

  defp find_or_insert_person(email, name) do
    find_person(email) || insert_person(email, name)
  end

  defp find_person(email) do
    email |> Person.with_email() |> Repo.one()
  end

  defp insert_person(email, name) do
    person = if name == "" do
      Person.with_fake_data()
    else
      %Person{name: name, handle: Faker.handle(name)}
    end

    person
    |> Person.insert_changeset(%{email: email})
    |> Repo.insert!()
  end
end
