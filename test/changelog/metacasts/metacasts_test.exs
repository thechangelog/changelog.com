defmodule Changelog.MetacastsTest do
  use Changelog.SchemaCase

  alias Changelog.Episode
  alias Changelog.EpisodeTracker
  alias Changelog.Metacasts.Filterer

  @statement_limit 256

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

  test "flatten episodes and filter them" do
    assert {:ok, episodes} = Episode.flatten_for_filtering()
    assert length(episodes) == 2

    assert [_] = Filterer.filter!(episodes, "only podcast: podcast") |> Enum.to_list()
    assert [] = Filterer.filter!(episodes, "only podcast: gotime") |> Enum.to_list()
    assert [_, _] = Filterer.filter!(episodes, "except topic: react") |> Enum.to_list()
  end

  test "filter via EpisodeTracker" do
    EpisodeTracker.refresh()
    assert {:ok, [%{slug: "rails-episode"}]} = EpisodeTracker.filter("only podcast: podcast")
    assert {:ok, ["rails-episode"]} = EpisodeTracker.filter(
      "only podcast: podcast",
      fn episode ->
        episode.slug
    end)
    assert {:ok, [2]} = EpisodeTracker.get_episodes_as_ids("only podcast: podcast")
  end

  test "filter statement abuse limit" do
    too_many_statements = Enum.reduce(0..@statement_limit, "except ", fn num, query ->
      query <> " podcast: podcast-#{num}"
    end)

    assert {:error, :too_many_statements} = Filterer.compile(too_many_statements)
  end
end