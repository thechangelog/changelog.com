defmodule Changelog.Repo.Migrations.ChangeNewsItemAudioObjectIdAwayFromSlugs do
  use Ecto.Migration

  alias Changelog.{Episode, NewsItem, Repo}

  def up do
    for item <- NewsItem.audio() |> Repo.all() do
      [podcast_slug, episode_slug] = String.split(item.object_id, ":")

      # only operate on object that are currently using slugs
      if String.match?(podcast_slug, ~r/[a-z]+/) do
        episode =
          Episode
          |> Episode.with_podcast_slug(podcast_slug)
          |> Episode.with_slug(episode_slug)
          |> Repo.one()

        new_object_id = "#{episode.podcast_id}:#{episode.id}"

        item
        |> Ecto.Changeset.change(%{object_id: new_object_id})
        |> Repo.update()
      end
    end
  end

  def down do
    for item <- NewsItem.audio() |> Repo.all() do
      [podcast_id, episode_id] = String.split(item.object_id, ":")

      # only operate on object that are currently using integer ids
      unless String.match?(podcast_id, ~r/[a-z]+/) do
        episode =
          Episode
          |> Repo.get(episode_id)
          |> Repo.preload(:podcast)

        new_object_id = "#{episode.podcast.slug}:#{episode.slug}"

        item
        |> Ecto.Changeset.change(%{object_id: new_object_id})
        |> Repo.update()
      end
    end
  end
end
