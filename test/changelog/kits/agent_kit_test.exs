defmodule Changelog.AgentKitTest do
  use ExUnit.Case

  alias Changelog.AgentKit

  describe "is_overcast/1" do
    test "is false when nil or empty agent" do
      refute AgentKit.is_overcast(nil)
      refute AgentKit.is_overcast("")
    end

    test "is true when Overcast user agent matches" do
      agent = "Overcast/1.0 Podcast Sync (1190 subscribers; feed-id=554901; +http://overcast.fm/)"
      assert AgentKit.is_overcast(agent)
    end
  end

  describe "get_overcast_subs/1" do
    test "returns :error and message when agent isn't Overcast" do
      agent = "Mozilla whatever whatever 11 subscribers"
      {result, _message} = AgentKit.get_overcast_subs(agent)
      assert result == :error
    end

    test "returns :error and message when sub count is 1 or less" do
      agent = "Overcast/1.0 Podcast Sync (1 subscribers; feed-id=554901; +http://overcast.fm/)"
      {result, _message} = AgentKit.get_overcast_subs(agent)
      assert result == :error
    end

    test "returns :ok and subscriber count" do
      agent = "Overcast/1.0 Podcast Sync (1190 subscribers; feed-id=554901; +http://overcast.fm/)"
      {:ok, count} = AgentKit.get_overcast_subs(agent)
      assert count == 1190
    end
  end
end
