defmodule Changelog.Repo.Migrations.AddMastodonTokenToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add(:mastodon_token, :string)
    end
  end
end
