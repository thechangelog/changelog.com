defmodule Changelog.Repo.Migrations.CreateEpisodeTopic do
  use Ecto.Migration

  def change do
    create table(:episode_topics) do
      add :position, :integer
      add :topic_id, references(:topics, on_delete: :nothing)
      add :episode_id, references(:episodes, on_delete: :nothing)

      timestamps()
    end

    create index(:episode_topics, [:topic_id])
    create index(:episode_topics, [:episode_id])
    create unique_index(:episode_topics, [:episode_id, :topic_id])
  end
end
