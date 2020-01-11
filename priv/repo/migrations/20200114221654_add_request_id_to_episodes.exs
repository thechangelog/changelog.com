defmodule Changelog.Repo.Migrations.AddRequestIdToEpisodes do
  use Ecto.Migration

  def change do
    drop index(:episode_requests, [:episode_id])

    alter table(:episode_requests) do
      remove :episode_id
    end

    alter table(:episodes) do
      add :request_id, references(:episode_requests)
    end

    create index(:episodes, [:request_id])
  end
end
