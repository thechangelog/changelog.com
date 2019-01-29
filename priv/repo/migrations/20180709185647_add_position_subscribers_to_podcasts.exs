defmodule Changelog.Repo.Migrations.AddPositionSubscribersToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :position, :integer
      add :subscribers, :jsonb
    end
  end
end
