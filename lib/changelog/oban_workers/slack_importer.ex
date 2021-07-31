defmodule Changelog.ObanWorkers.SlackImporter do
  use Oban.Worker, queue: :scheduled

  alias Changelog.{Person, Repo}
  alias Changelog.Slack.Client

  import Ecto.Query

  @impl Oban.Worker
  def perform(_job) do
    %{"members" => members} = Client.list()

    for %{"id" => id, "profile" => profile} <- members do
      email = Map.get(profile, "email", "")

      import_member_id(id, email)
    end

    :ok
  end

  def import_member_id(id, email) do
    Person
    |> where([p], p.email == ^email)
    |> where([p], is_nil(p.slack_id) or p.slack_id == "pending")
    |> Repo.update_all(set: [slack_id: id])
  end
end
