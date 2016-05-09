defmodule Changelog.Repo.Migrations.RenameTopicsToChannels do
  use Ecto.Migration

  def change do
    rename table(:topics), to: table(:channels)

    alter table(:channels) do
      remove :website
    end

    drop index(:episode_topics, [:topic_id])
    drop unique_index(:episode_topics, [:episode_id, :topic_id])

    rename table(:episode_topics), to: table(:episode_channels)
    rename table(:episode_channels), :topic_id, to: :channel_id

    create index(:episode_channels, [:channel_id])
    create unique_index(:episode_channels, [:episode_id, :channel_id])
  end
end
