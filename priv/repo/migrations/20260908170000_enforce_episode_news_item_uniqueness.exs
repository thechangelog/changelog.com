defmodule Changelog.Repo.Migrations.EnforceEpisodeNewsItemUniqueness do
  use Ecto.Migration

  def up do
    execute("SET LOCAL lock_timeout = '2s'")
    execute("SET LOCAL statement_timeout = '20s'")

    # Episode object IDs span every podcast and publish mode, not just audio rows.
    create(
      unique_index(:news_items, [:object_id],
        name: :news_items_episode_object_id_unique,
        where: "object_id ~ '^[1-9][0-9]*:[1-9][0-9]*$'"
      )
    )
  end

  def down do
    execute("SET LOCAL lock_timeout = '2s'")
    execute("SET LOCAL statement_timeout = '20s'")

    drop(index(:news_items, [:object_id], name: :news_items_episode_object_id_unique))
  end
end
