defmodule Changelog.Repo.Migrations.AddIconToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :icon, :string
    end
  end
end
