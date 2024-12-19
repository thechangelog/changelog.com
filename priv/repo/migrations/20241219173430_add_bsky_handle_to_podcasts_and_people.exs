defmodule Changelog.Repo.Migrations.AddBskyHandleToPodcastsAndPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:bsky_handle, :string)
    end

    alter table(:podcasts) do
      add(:bsky_handle, :string)
    end

    create unique_index(:people, [:bsky_handle])
    create unique_index(:podcasts, [:bsky_handle])
  end
end
