defmodule Changelog.IcecastTest do
  use ExUnit.Case

  import Mock

  alias Changelog.Icecast

  describe "get_stats" do
    test "is not streaming on decode error" do
      with_mock(HTTPoison, get!: fn _ -> %{status_code: 200, body: ""} end) do
        stats = Icecast.get_stats()
        assert called(HTTPoison.get!(:_))
        refute stats.streaming
      end
    end

    test "is streaming with listeners when appropriate" do
      body = %{"icestats" => %{"source" => %{"listeners" => 3}}}

      with_mock(HTTPoison, get!: fn _ -> %{status_code: 200, body: Jason.encode!(body)} end) do
        stats = Icecast.get_stats()
        assert called(HTTPoison.get!(:_))
        assert stats.streaming
        assert stats.listeners == 3
      end
    end
  end
end
