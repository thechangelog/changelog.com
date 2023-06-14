defmodule Mix.Tasks.Changelog.NoSpam do
  use Mix.Task

  alias ChangelogWeb.PersonView
  alias Changelog.{Newsletters, Person, Repo}

  @shortdoc "Purges all spam person records"

  def run(_) do
    Mix.Task.run("app.start")

    older_than =
      case System.get_env("OLDER_THAN") do
        nil ->
          Timex.today()

        date ->
          {:ok, yup} = Date.from_iso8601(date)
          yup
      end

    spammy = Person.spammy() |> Person.older_than(older_than) |> Repo.all()

    results = Enum.map(spammy, fn person ->
      if PersonView.is_subscribed(person, Newsletters.nightly()) do
        IO.puts("Skipping Nightly subscriber #{person.id} #{person.name} (#{person.email})")
        false
      else
        IO.puts("Purging #{person.id} #{person.name} (#{person.email})")
        Repo.delete!(person)
        true
      end
    end)

    purged_count = results |> Enum.filter(&(&1)) |> length()
    skipped_count = results |> Enum.filter(&(!&1)) |> length()

    IO.puts("Finished purging #{purged_count} spam accounts older than #{older_than}, Skipped #{skipped_count}")
  end
end
