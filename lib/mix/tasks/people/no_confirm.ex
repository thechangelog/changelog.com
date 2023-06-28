defmodule Mix.Tasks.Changelog.NoConfirm do
  use Mix.Task

  alias Changelog.{Newsletters, Person, Repo, Subscription}
  alias ChangelogWeb.PersonView

  @shortdoc "Purges people $OLDER_THAN (default: 1 week ago) who have not confirmed their account"

  def run(_) do
    Mix.Task.run("app.start")

    older_than =
      case System.get_env("OLDER_THAN") do
        nil ->
          Timex.today() |> Timex.shift(weeks: -1)

        date ->
          {:ok, yup} = Date.from_iso8601(date)
          yup
      end

    people = Person.older_than(older_than) |> Person.needs_confirmation() |> Repo.all()

    results = Enum.map(people, fn person ->
      person = Person.preload_subscriptions(person)

      if PersonView.is_subscribed(person, Newsletters.nightly()) do
        IO.puts("Skipping Nightly subscriber #{person.id} #{person.name} (#{person.email})")
        false
      else
        IO.puts("Purging #{person.id} #{person.name} (#{person.email})")
        Repo.delete!(person)
        true
      end
    end)

    true_count = results |> Enum.filter(&(&1)) |> length()
    false_count = results |> Enum.filter(&(!&1)) |> length()

    IO.puts("Purged #{true_count} people older than #{older_than}. #{false_count} skipped.")
  end

  def confirm_weekly_subs do
    for sub <- Subscription.subscribed() |> Subscription.preload_person() |> Repo.all() do
      if is_nil(sub.person.joined_at) && String.match?(sub.context, ~r/Changelog Weekly/) do
        {:ok, utc_inserted_at} = DateTime.from_naive(sub.inserted_at, "Etc/UTC")
        Ecto.Changeset.change(sub.person, %{joined_at: utc_inserted_at}) |> Repo.update()
      end
    end
  end
end
