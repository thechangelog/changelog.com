defmodule Mix.Tasks.Changelog.NoSpam do
  use Mix.Task

  alias Changelog.{Newsletters, Person, Repo}
  alias Craisin.Subscriber

  @shortdoc "Purges all spam person records"

  def run(_) do
    Mix.Task.run "app.start"

    fakers = Person.faked() |> Person.never_signed_in()

    for person <- Repo.all(fakers) do
      IO.puts "Purging #{person.id} #{person.name} (#{person.email})"
      Subscriber.delete(Newsletters.weekly().list_id, person.email)
      Subscriber.delete(Newsletters.nightly().list_id, person.email)
      Repo.delete!(person)
    end

    IO.puts "Finished purging #{Repo.count(fakers)} fakes"
  end
end
