defmodule Changelog.Repo.Migrations.FixPeopleNameIndex do
  use Ecto.Migration

  def change do
    drop index(:people, [:name], unique: true)
    create index(:people, [:name])
  end
end
