defmodule Changelog.Repo.Migrations.AddTranscriptToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add(:transcript, {:array, :map}, default: [])
    end
  end
end
