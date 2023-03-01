defmodule Changelog.Repo.Migrations.AddSocialUrlToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :socialize_url, :string
    end
  end
end
