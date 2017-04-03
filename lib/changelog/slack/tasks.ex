defmodule Changelog.Slack.Tasks do
  alias Changelog.{Person, Repo}
  alias Changelog.Slack.Client

  import Ecto.Query

  def import_member_ids do
    list = Client.list()

    for member <- Map.get(list, "members") do
      id = Map.get(member, "id")
      email = get_in(member, ["profile", "email"]) || ""

      query = from p in Person,
        where: p.email == ^email,
        where: is_nil(p.slack_id) or p.slack_id == "pending"

      if person = Repo.one(query) do
        Repo.update(Ecto.Changeset.change(person, slack_id: id))
      end
    end
  end
end
