defmodule Changelog.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :string
      add :plusplus, :boolean, default: false
      add :autosub, :boolean, default: true
      add :cover, :string
      add :title_format, :string
      add :starts_at, :utc_datetime
      add :owner_id, references(:people, on_delete: :delete_all)
      add :podcast_ids, {:array, :integer}
      add :person_ids, {:array, :integer}

      timestamps()
    end

    create unique_index(:feeds, [:slug])

    execute "CREATE INDEX idx_feeds_podcast_ids ON feeds USING GIN (podcast_ids);", "DROP INDEX idx_feeds_podcast_ids;"
    execute "CREATE INDEX idx_feeds_person_ids ON feeds USING GIN (person_ids);", "DROP INDEX idx_feeds_person_ids;"
  end
end
