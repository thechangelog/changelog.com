defmodule Changelog.Repo.Migrations.AddYoutubeUrlsToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :youtube_url, :string
      add :clips_url, :string
      remove :chartable_id
    end
  end
end
