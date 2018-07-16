defmodule Changelog.Repo.Migrations.AddHostAndEditorFlagsToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :host, :boolean, default: false
      add :editor, :boolean, default: false
    end
  end
end
