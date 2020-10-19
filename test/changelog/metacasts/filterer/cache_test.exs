defmodule Changelog.Metacasts.Filterer.CacheTest do
  use ExUnit.Case

  alias Changelog.Metacasts.Filterer.Cache

  @episodes [
    %{
      id: 1,
      podcast: "rfc",
      host: [],
      guest: [],
      topic: []
    },
    %{
      id: 2,
      podcast: "afk",
      host: [],
      guest: [],
      topic: []
    },
    %{
      id: 3,
      podcast: "gotime",
      host: [],
      guest: [],
      topic: []
    }
  ]

  test "basic operations" do
    filter_string = "only podcast: rfc"
    assert {:ok, compiled} = Cache.compile(filter_string)
    assert %{"only podcast: rfc" => ^compiled} = Cache.stat()
    assert [%{id: 1}] = Cache.filter!(@episodes, filter_string) |> Enum.to_list()
    assert {:ok, stream} = Cache.filter(@episodes, filter_string)
    assert [%{id: 1}] = Enum.to_list(stream)

    second_filter = "except podcast: rfc"
    assert [%{id: 2}, %{id: 3}] = Cache.filter!(@episodes, second_filter) |> Enum.to_list()
    assert [%{id: 2}, %{id: 3}] = Cache.filter!(@episodes, second_filter) |> Enum.to_list()
    assert %{"only podcast: rfc" => _, "except podcast: rfc" => _} = Cache.stat()
  end
end
