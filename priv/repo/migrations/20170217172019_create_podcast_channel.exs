defmodule Changelog.Repo.Migrations.CreatePodcastChannel do
  use Ecto.Migration

  def change do
    create table(:podcast_channels) do
      add :position, :integer
      add :podcast_id, references(:podcasts)
      add :channel_id, references(:channels)

      timestamps()
    end

    create index(:podcast_channels, [:podcast_id])
    create index(:podcast_channels, [:channel_id])
    create unique_index(:podcast_channels, [:podcast_id, :channel_id])
  end
end
