defmodule Changelog.Repo.Migrations.AddGuidToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:guid, :string)
    end
  end
end
