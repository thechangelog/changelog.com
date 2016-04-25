defmodule Changelog.Repo.Migrations.AddAudioFileToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :audio_file, :string
    end
  end
end
