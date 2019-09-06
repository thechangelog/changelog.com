defmodule Changelog.Repo.Migrations.CreateEpisodeRequests do
  use Ecto.Migration

  def change do
    create table(:episode_requests) do
      add :status, :integer, null: false, default: 0
      add :hosts, :string
      add :guests, :string
      add :topics, :string
      add :pronunciation, :string
      add :pitch, :text

      add :submitter_id, references(:people, on_delete: :delete_all)
      add :podcast_id, references(:podcasts, on_delete: :delete_all)
      add :episode_id, references(:episodes, on_delete: :delete_all)

      timestamps()
    end

    create index(:episode_requests, [:submitter_id])
    create index(:episode_requests, [:podcast_id])
    create index(:episode_requests, [:episode_id])
    create index(:episode_requests, [:status])
  end
end
