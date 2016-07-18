defmodule Changelog.Repo.Migrations.AdjustPodcastFields do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      remove :cover_art
      add :status, :integer, default: 0
      add :schedule_note, :string
    end

    create index(:podcasts, [:status])
  end
end
