defmodule Changelog.Repo.Migrations.DropUnusedIndexes do
  use Ecto.Migration

  def up do
    execute "DROP INDEX episode_guests_episode_id_index;"
    execute "DROP INDEX episode_hosts_episode_id_index;"
    execute "DROP INDEX episode_sponsors_episode_id_index;"
    execute "DROP INDEX episode_stats_date_index;"
    execute "DROP INDEX episode_topics_episode_id_index;"
    execute "DROP INDEX news_issue_ads_issue_id_index;"
    execute "DROP INDEX news_issue_items_issue_id_index;"
    execute "DROP INDEX news_item_topics_item_id_index;"
    execute "DROP INDEX podcast_hosts_podcast_id_index;"
    execute "DROP INDEX podcast_topics_podcast_id_index;"
    execute "DROP INDEX post_topics_post_id_index;"

    drop table(:metacasts)
  end

  def down do
  end
end
