defmodule Mix.Tasks.Changelog.Subscriptions do
  use Mix.Task

  alias Changelog.{Faker, Person, Podcast, Repo, Subscription}
  alias ChangelogWeb.PersonView
  alias NimbleCSV.RFC4180, as: CSV

  require Logger

  @shortdoc "Imports people and subscriptions from CSV"

  def run([import_file]),
    do: run([import_file, "you subscribed way back in the day (pre-launch)"])

  def run([import_file, context]) do
    Mix.Task.run("app.start")

    podcast =
      import_file
      |> Path.basename()
      |> String.replace_trailing(".csv", "")
      |> Podcast.get_by_slug!()

    Logger.info(
      "Prior to run: #{podcast.name} has #{Podcast.subscription_count(podcast)} subscribers. #{Repo.count(Person)} total people."
    )

    import_file
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn [name, email, _rest] -> [String.trim(name), String.trim(email)] end)
    |> Enum.each(fn [name, email] ->
      email
      |> find_or_insert_person(name)
      |> subscribe_if_not_already(podcast, context)
    end)

    Logger.info(
      "After run: #{podcast.name} has #{Podcast.subscription_count(podcast)} subscribers. #{Repo.count(Person)} total people."
    )
  end

  defp subscribe_if_not_already(person, podcast, context) do
    if !PersonView.is_subscribed(person, podcast) do
      Subscription.subscribe(person, podcast, context)
    end
  end

  defp find_or_insert_person(email, name) do
    find_person(email) || insert_person(email, name)
  end

  defp find_person(email) do
    email |> Person.with_email() |> Repo.one()
  end

  defp insert_person(email, name) do
    person =
      if name == "" do
        Person.with_fake_data()
      else
        %Person{name: name, handle: Faker.handle(name), public_profile: false}
      end

    person
    |> Person.insert_changeset(%{email: email})
    |> Repo.insert!()
  end
end
