defmodule Changelog.Repo.Migrations.RenameChannelsToTopics do
  use Ecto.Migration

  def change do
    # channels -> topics
    rename table(:channels), to: table(:topics)

    # episode channels -> episode topics
    drop index(:episode_channels, [:channel_id])
    drop unique_index(:episode_channels, [:episode_id, :channel_id])

    rename table(:episode_channels), :channel_id, to: :topic_id
    rename table(:episode_channels), to: table(:episode_topics)

    create index(:episode_topics, [:topic_id])
    create unique_index(:episode_topics, [:episode_id, :topic_id])

    # podcast channels -> podcast topics
    drop index(:podcast_channels, [:channel_id])
    drop index(:podcast_channels, [:podcast_id])
    drop unique_index(:podcast_channels, [:podcast_id, :channel_id])

    rename table(:podcast_channels), :channel_id, to: :topic_id
    rename table(:podcast_channels), to: table(:podcast_topics)

    create index(:podcast_topics, [:topic_id])
    create index(:podcast_topics, [:podcast_id])
    create unique_index(:podcast_topics, [:podcast_id, :topic_id])

    # post channels -> post topics
    drop index(:post_channels, [:channel_id])
    drop index(:post_channels, [:post_id])
    drop unique_index(:post_channels, [:post_id, :channel_id])

    rename table(:post_channels), :channel_id, to: :topic_id
    rename table(:post_channels), to: table(:post_topics)

    create index(:post_topics, [:topic_id])
    create index(:post_topics, [:post_id])
    create unique_index(:post_topics, [:post_id, :topic_id])
  end
end
