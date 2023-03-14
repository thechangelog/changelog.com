defmodule Mix.Tasks.Changelog.NoSpam do
  use Mix.Task

  alias Changelog.{Newsletters, Person, Repo}
  alias Craisin.Subscriber

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

    fakers =
      Person.faked()
      |> Person.never_signed_in()
      |> Person.older_than(older_than)

    fakers_count = Repo.count(fakers)

    for person <- Repo.all(fakers) do
      IO.puts("Purging #{person.id} #{person.name} (#{person.email})")
      Subscriber.delete(Newsletters.weekly().id, person.email)
      Subscriber.delete(Newsletters.nightly().id, person.email)
      Repo.delete!(person)
    end

    IO.puts("Finished purging #{fakers_count} fakes older than #{older_than}")
  end
end
