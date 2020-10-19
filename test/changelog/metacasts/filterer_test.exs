defmodule Changelog.Metacasts.FiltererTest do
  use Changelog.SchemaCase
  doctest Changelog.Metacasts.Filterer

  @statement_limit 256
  alias Changelog.Episode
  alias Changelog.Metacasts.Filterer

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
     ]}
  end

  test "flatten episodes and filter them" do
    assert {:ok, episodes} = Episode.flatten_for_filtering()
    assert length(episodes) == 2

    assert [_] = Filterer.filter!(episodes, "only podcast: podcast") |> Enum.to_list()
    assert [] = Filterer.filter!(episodes, "only podcast: gotime") |> Enum.to_list()
    assert [_, _] = Filterer.filter!(episodes, "except topic: react") |> Enum.to_list()
  end

  test "filter statement abuse limit" do
    too_many_statements =
      Enum.reduce(0..@statement_limit, "except ", fn num, query ->
        query <> " podcast: podcast-#{num}"
      end)

    assert {:error, :too_many_statements} = Filterer.compile(too_many_statements)
  end
end
