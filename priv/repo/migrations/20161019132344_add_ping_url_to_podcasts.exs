defmodule Changelog.Repo.Migrations.AddPingUrlToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add(:ping_url, :string)
    end
  end
end
