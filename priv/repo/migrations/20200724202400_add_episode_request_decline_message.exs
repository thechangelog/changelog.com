defmodule Changelog.Repo.Migrations.AddEpisodeRequestDeclineMessage do
  use Ecto.Migration

  def change do
    alter table(:episode_requests) do
      add :decline_message, :string, default: ""
    end
  end
end
