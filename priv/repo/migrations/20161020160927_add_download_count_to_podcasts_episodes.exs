defmodule Changelog.Repo.Migrations.AddDownloadCountToPodcastsEpisodes do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add(:download_count, :float, default: 0.0)
    end

    alter table(:episodes) do
      add(:download_count, :float, default: 0.0)
      add(:import_count, :float, default: 0.0)
    end
  end
end
