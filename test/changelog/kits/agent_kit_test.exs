defmodule Changelog.AgentKitTest do
  use ExUnit.Case

  alias Changelog.AgentKit

  describe "identify/1" do
    test "it matches bot agents" do
      ua = "Mozilla/5.0 (compatible; AhrefsBot/6.1; +http://ahrefs.com/robot/)"

      assert AgentKit.identify(ua) == %{type: "bot", name: "AhrefsBot"}
    end

    test "it matches app agents" do
      ua = "Overcast (+http://overcast.fm/; Apple Watch podcast app)"

      assert AgentKit.identify(ua) == %{type: "app", name: "Overcast"}
    end

    test "it matches library agents" do
      ua = "Deno/1.26.1"

      assert AgentKit.identify(ua) == %{type: "library", name: "Deno"}
    end

    test "it matches browser agents" do
      ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"

      assert AgentKit.identify(ua) == %{type: "browser", name: "iOS WebView"}
    end
  end
end
