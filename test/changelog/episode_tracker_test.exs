defmodule Changelog.MetacastsTest do
  use Changelog.SchemaCase

  alias Changelog.EpisodeTracker

  setup do
    gotime = insert(:podcast, slug: "gotime")
    changelog = insert(:podcast, slug: "podcast")
    jsparty = insert(:podcast, slug: "jsparty")
    {:ok,
    podcasts: [gotime, changelog, jsparty],
    episodes: [
            insert(:published_episode,
                id: 1,
                slug: "phoenix-liveview-episode",
                title: "Phoenix LiveView",
                summary: "A web framework for Elixir",
                notes: "Chris McCord",
                podcast: jsparty
            ),
            insert(:published_episode,
                id: 2,
                slug: "rails-episode",
                title: "Rails",
                summary: "A web framework for Ruby",
                notes: "DHH",
                podcast: changelog
            )
        ]
    }
  end

  test "filter" do
    EpisodeTracker.refresh()
    assert {:ok, [%{slug: "rails-episode"}]} = EpisodeTracker.filter("only podcast: podcast")
    assert {:ok, ["rails-episode"]} = EpisodeTracker.filter(
      "only podcast: podcast",
      fn episode ->
        episode.slug
    end)
    assert {:ok, [2]} = EpisodeTracker.get_episodes_as_ids("only podcast: podcast")
  end

  test "track new episode then untrack", %{podcasts: [_, changelog, _]} do
    EpisodeTracker.refresh()
    episode = insert(:published_episode,
        id: 3,
        slug: "django-episode",
        title: "Django",
        summary: "A web framework for Python",
        notes: "?",
        podcast: changelog
    )
    assert {:ok, [%{slug: "rails-episode"}]} = EpisodeTracker.filter("only podcast: podcast")
    EpisodeTracker.track(episode)
    assert {:ok, [%{slug: "django-episode"}, %{slug: "rails-episode"}]} = EpisodeTracker.filter("only podcast: podcast")
    EpisodeTracker.untrack(episode.id)
    assert {:ok, [%{slug: "rails-episode"}]} = EpisodeTracker.filter("only podcast: podcast")
  end
end