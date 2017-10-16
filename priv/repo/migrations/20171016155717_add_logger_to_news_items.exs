defmodule Changelog.Repo.Migrations.AddLoggerToNewsItems do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      add :logger_id, references(:people)
    end
    create index(:news_items, [:logger_id])
  end
end
