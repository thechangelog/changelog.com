defmodule Changelog.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :published, :boolean, default: false
      add :published_at, :naive_datetime
      add :body, :text
      add :author_id, references(:people, on_delete: :nothing)

      timestamps()
    end

    create index(:posts, [:author_id])
    create unique_index(:posts, [:slug])
  end
end
