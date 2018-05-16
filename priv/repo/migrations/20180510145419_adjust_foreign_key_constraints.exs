defmodule Changelog.Repo.Migrations.AdjustForeignKeyConstraints do
  use Ecto.Migration

  @cascades [
    {"episode_guests", "person_id", "people"},
    {"episode_guests", "episode_id", "episodes"},
    {"episode_hosts", "person_id", "people"},
    {"episode_hosts", "episode_id", "episodes"},
    {"episode_sponsors", "sponsor_id", "sponsors"},
    {"episode_sponsors", "episode_id", "episodes"},
    {"episode_stats", "episode_id", "episodes"},
    {"episode_stats", "podcast_id", "podcasts"},
    {"episode_topics", "episode_id", "episodes"},
    {"episode_topics", "topic_id", "topics"},
    {"news_issue_ads", "issue_id", "news_issues"},
    {"news_issue_ads", "ad_id", "news_ads"},
    {"news_issue_items", "issue_id", "news_issues"},
    {"news_issue_items", "item_id", "news_items"},
    {"news_queue", "item_id", "news_items"},
    {"news_item_topics", "item_id", "news_items"},
    {"news_item_topics", "topic_id", "topics"},
    {"news_sponsorships", "sponsor_id", "sponsors"},
    {"podcast_hosts", "person_id", "people"},
    {"podcast_hosts", "podcast_id", "podcasts"},
    {"podcast_topics", "podcast_id", "podcasts"},
    {"podcast_topics", "topic_id", "topics"},
    {"post_topics", "post_id", "posts"},
    {"post_topics", "topic_id", "topics"},
    {"posts", "author_id", "people"},
    {"news_items", "logger_id", "people"}
  ]

  @nullifies [
    {"news_items", "author_id", "people"},
    {"news_items", "source_id", "news_sources"},
    {"news_items", "submitter_id", "people"},
  ]

  @renames [
    {"podcast_topics", "podcast_channels_podcast_id_fkey", "podcast_topics_podcast_id_fkey"},
    {"podcast_topics", "podcast_channels_channel_id_fkey", "podcast_topics_topic_id_fkey"},
    {"post_topics", "post_channels_channel_id_fkey", "post_topics_topic_id_fkey"},
    {"post_topics", "post_channels_post_id_fkey", "post_topics_post_id_fkey"}
  ]

  def up do
    for {table, from, to} <- @renames do
      execute "ALTER TABLE #{table} RENAME CONSTRAINT #{from} to #{to}"
    end

    for {table, key, references} <- @cascades do
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_#{key}_fkey, ADD CONSTRAINT #{table}_#{key}_fkey FOREIGN KEY (#{key}) REFERENCES #{references} (id) ON DELETE CASCADE"
    end

    for {table, key, references} <- @nullifies do
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_#{key}_fkey, ADD CONSTRAINT #{table}_#{key}_fkey FOREIGN KEY (#{key}) REFERENCES #{references} (id) ON DELETE SET NULL"
    end
  end

  def down do
    for {table, key, references} <- @cascades ++ @nullifies do
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_#{key}_fkey, ADD CONSTRAINT #{table}_#{key}_fkey FOREIGN KEY (#{key}) REFERENCES #{references} (id)"
    end

    for {table, to, from} <- @renames do
      execute "ALTER TABLE #{table} RENAME CONSTRAINT #{from} to #{to}"
    end
  end
end
