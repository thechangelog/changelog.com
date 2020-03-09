defmodule Changelog.Repo.Migrations.AddEditorCoverSubtitleToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :image, :string
      add :subtitle, :string
      add :editor_id, references(:people)
    end

    create index(:posts, [:editor_id])
  end
end
