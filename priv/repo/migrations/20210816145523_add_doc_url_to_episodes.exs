defmodule Changelog.Repo.Migrations.AddDocUrlToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :doc_url, :string
    end
  end
end
