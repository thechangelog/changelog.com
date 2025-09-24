defmodule Mix.Tasks.Changelog.PrivateProfiles do
  use Mix.Task

  alias Changelog.{Person, Repo}

  require Logger

  @shortdoc "Sets all profiles private for people who haven't been on an episode"

  def run(_) do
    Mix.Task.run("app.start")

    Logger.configure(level: :info)

    public = Person |> Person.with_public_profile() |> Repo.all()

    Logger.info("There are #{length(public)} people with public profiles.")

    no_ep_ids =
      public
      |> Enum.reject(fn person -> Person.episode_count(person) > 0 end)
      |> Enum.map(& &1.id)

    Logger.info("Of those, #{length(no_ep_ids)} people have never been on an episode.")

    no_ep_ids
    |> Person.with_ids()
    |> Repo.update_all(set: [public_profile: false])
  end
end
