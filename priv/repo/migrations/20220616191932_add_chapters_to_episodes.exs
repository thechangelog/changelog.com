defmodule Changelog.Repo.Migrations.AddChaptersToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :audio_chapters, {:array, :map}, default: []
      add :plusplus_chapters, {:array, :map}, default: []
    end
  end
end
