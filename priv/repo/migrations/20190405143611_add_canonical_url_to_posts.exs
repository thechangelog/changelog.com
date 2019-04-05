defmodule Changelog.Repo.Migrations.AddCanonicalUrlToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :canonical_url, :string
    end
  end
end
