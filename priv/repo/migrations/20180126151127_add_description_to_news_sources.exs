defmodule Changelog.Repo.Migrations.AddDescriptionToNewsSources do
  use Ecto.Migration

  def change do
    alter table(:news_sources) do
      add :description, :text
    end
  end
end
