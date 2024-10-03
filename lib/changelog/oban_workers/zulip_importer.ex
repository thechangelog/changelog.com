defmodule Changelog.ObanWorkers.ZulipImporter do
  use Oban.Worker, queue: :scheduled

  alias Changelog.{Person, Repo}
  alias Changelog.Zulip.Client

  @impl Oban.Worker
  def perform(_job) do
    case Client.get_users() do
      %{"ok" => true, "members" => members} ->
        for %{"user_id" => id, "email" => email} <- members do
          import_member_id(id, email)
        end

        :ok
      %{"ok" => false} ->
        :ok
    end
  end

  def import_member_id(id, email) do
    Person
    |> Person.not_in_zulip()
    |> Person.with_email(email)
    |> Repo.update_all(set: [zulip_id: "#{id}"])
  end
end
