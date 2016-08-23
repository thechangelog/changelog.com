defmodule Changelog.Repo.Migrations.AddTldrToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :tldr, :text
    end
  end
end
