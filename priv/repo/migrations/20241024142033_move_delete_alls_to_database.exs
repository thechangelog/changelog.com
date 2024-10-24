defmodule Changelog.Repo.Migrations.MoveDeleteAllsToDatabase do
  use Ecto.Migration

  def up do
    drop constraint(:feed_stats, :feed_stats_feed_id_fkey)

    alter table(:feed_stats) do
      modify(:feed_id, references(:feeds, on_delete: :delete_all))
    end

    drop constraint(:news_item_comments, :news_item_comments_item_id_fkey)

    alter table(:news_item_comments) do
      modify(:item_id, references(:news_items, on_delete: :delete_all))
    end

    drop constraint(:news_ads, :news_ads_sponsorship_id_fkey)

    alter table(:news_ads) do
      modify(:sponsorship_id, references(:news_sponsorships, on_delete: :delete_all))
    end

    drop constraint(:sponsor_reps, :sponsor_reps_sponsor_id_fkey)

    alter table(:sponsor_reps) do
      modify(:sponsor_id, references(:sponsors, on_delete: :delete_all))
    end

    drop constraint(:sponsor_reps, :sponsor_reps_person_id_fkey)

    alter table(:sponsor_reps) do
      modify(:person_id, references(:people, on_delete: :delete_all))
    end
  end

  def down do
    # do nothing because the `up` is idempotent
  end
end
