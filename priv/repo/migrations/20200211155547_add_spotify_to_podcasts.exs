defmodule Changelog.Repo.Migrations.AddSpotifyToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add(:spotify_url, :string)
      add(:welcome, :text)
    end

    rename table(:podcasts), :itunes_url, to: :apple_url
  end
end
