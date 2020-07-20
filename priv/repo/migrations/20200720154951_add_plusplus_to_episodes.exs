defmodule Changelog.Repo.Migrations.AddPlusplusToEpisodes do
  use Ecto.Migration

  def change do
    rename table(:episodes), :bytes, to: :audio_bytes
    rename table(:episodes), :duration, to: :audio_duration

    alter table(:episodes) do
      add :plusplus_file, :string
      add :plusplus_bytes, :integer, default: 0
      add :plusplus_duration, :integer
    end
  end
end
