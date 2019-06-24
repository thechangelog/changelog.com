defmodule Changelog.Repo.Migrations.AddImageBooleanToNewsIssueItems do
  use Ecto.Migration
  import Ecto.Query

  alias Changelog.{NewsAd, NewsItem, Repo}

  def up do
    alter table(:news_issue_items) do
      add :image, :boolean, default: false
    end

    alter table(:news_issue_ads) do
      add :image, :boolean, default: false
    end

    flush()

    for item <- Repo.all(NewsItem.with_image()) do
      from(i in "news_issue_items",
        update: [set: [image: true]],
        where: i.item_id == ^item.id)
      |> Repo.update_all([])
    end

    for ad <- Repo.all(NewsAd.with_image()) do
      from(a in "news_issue_ads",
        update: [set: [image: true]],
        where: a.ad_id == ^ad.id)
      |> Repo.update_all([])
    end
  end

  def down do
    alter table(:news_issue_items) do
      remove :image
    end

    alter table(:news_issue_ads) do
      remove :image
    end
  end
end
