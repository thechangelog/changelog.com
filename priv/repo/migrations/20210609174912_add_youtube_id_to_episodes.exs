defmodule Changelog.Repo.Migrations.AddYoutubeIdToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :youtube_id, :string
    end
  end
end
