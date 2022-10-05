defmodule Changelog.Repo.Migrations.AddNewsSourceIsPublicationBool do
  use Ecto.Migration

  def change do
    alter table(:news_sources) do
      add :publication, :boolean, default: true
    end
  end
end
