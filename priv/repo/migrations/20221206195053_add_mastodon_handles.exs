defmodule Changelog.Repo.Migrations.AddMastodonHandles do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:mastodon_handle, :string)
    end

    alter table(:podcasts) do
      add(:mastodon_handle, :string)
    end
  end
end
