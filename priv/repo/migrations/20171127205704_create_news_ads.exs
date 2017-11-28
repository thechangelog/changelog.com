defmodule Changelog.Repo.Migrations.CreateNewsAds do
  use Ecto.Migration

  def change do
    create table(:news_ads) do
      add :url, :string, null: false
      add :headline, :string, null: false
      add :story, :text
      add :image, :string
      add :newsletter, :boolean, default: false, null: false
      add :active, :boolean, default: true, null: false
      add :impression_count, :integer, default: 0
      add :click_count, :integer, default: 0
      add :sponsorship_id, references(:news_sponsorships)

      timestamps()
    end

    create index(:news_ads, [:sponsorship_id])
    create index(:news_ads, [:active])
  end
end
