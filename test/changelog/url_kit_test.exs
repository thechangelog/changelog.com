defmodule Changelog.UrlKitTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.UrlKit

  describe "get_object_id" do
    test "defaults to nil" do
      assert is_nil(UrlKit.get_object_id(:link, nil))
    end

    test "returns podcast and episode slug when hosted audio" do
      assert UrlKit.get_object_id(:audio, "https://changelog.com/gotime/123") == "gotime:123"
      assert UrlKit.get_object_id(:audio, "https://changelog.com/rfc/15") == "rfc:15"
    end

    test "returns nil when non-hosted audio" do
      assert is_nil(UrlKit.get_object_id(:audio, "https://test.com/gotime/123"))
    end

    test "returns post and slug when hosted" do
      assert UrlKit.get_object_id(:announcement, "https://changelog.com/posts/oscon-2017-free-pass") == "posts:oscon-2017-free-pass"
    end

    test "returns nil when type has no known objects" do
      assert is_nil(UrlKit.get_object_id(:project, "https://test.com"))
    end
  end

  describe "get_source" do
    test "defaults to nil" do
      assert UrlKit.get_source(nil) == nil
      assert UrlKit.get_source("https://test.com") == nil
    end

    test "returns nil if there's a source with a bad regex" do
      insert(:news_source, regex: "*wired.com*")
      assert UrlKit.get_source("https://wired.com") == nil
    end

    test "returns the source when a match is found in the db" do
      wired = insert(:news_source, regex: "wired.com|twitter.com/wired")
      url = "https://www.wired.com/2017/10/things-we-loved-in-october/"
      assert UrlKit.get_source(url) == wired
      url = "https://twitter.com/wired/status/8675309"
      assert UrlKit.get_source(url) == wired
    end
  end

  describe "get_title" do
    test "defaults to empty string" do
      assert UrlKit.get_title(nil) == ""
    end

    test "extracts the page title" do
      url = "https://www.wired.com/2017/10/things-we-loved-in-october/"

      for body <- [~s{<title itemprop='name'>October's Best Gear</title>}, ~s{<title>October's Best Gear</title>}] do
        response = %{status_code: 200, headers: [], body: body}

        with_mock HTTPoison, [get!: fn(_, _, _) -> response end] do
          assert UrlKit.get_title(url) == "October's Best Gear"
          assert called HTTPoison.get!(url, [], [follow_redirect: true, max_redirect: 5])
        end
      end
    end
  end

  describe "extract_title" do
    test "when newlines are a thing" do
      html = """
      <head>
      <meta charset="utf-8">
      <title>
      GraphQL + Relay Modern + Rails //
      Collective Idea
      | Crafting web and mobile software based in Holland, Michigan
      </title>
      """

      assert UrlKit.extract_title(html) == "GraphQL + Relay Modern + Rails //"
    end

    test "when there are multiple title tags" do
      html = "<title>Are holograms the future of how we capture memories?</title><title>Part Deux</title."

      assert UrlKit.extract_title(html) == "Are holograms the future of how we capture memories?"
    end
  end

  describe "get_type" do
    test "defaults to link" do
      assert UrlKit.get_type(nil) == :link
      url = "https://example.com/whatevs?oh=yeah"
      assert UrlKit.get_type(url) == :link
    end

    test "returns project with a GitHub url" do
      url = "https://github.com/pixelandtonic/CommerceEasyPost"
      assert UrlKit.get_type(url) == :project
    end

    test "returns *not* a project with a GitHub blog url" do
      url = "https://github.com/blog"
      assert UrlKit.get_type(url) == :link
    end

    test "returns project with a GitLab url" do
      url = "https://gitlab.com/masterofolympus/le-maitre-des-titans"
      assert UrlKit.get_type(url) == :project
    end

    test "returns *not* a project with a GitLab about url" do
      url = "https://about.gitlab.com/features"
      assert UrlKit.get_type(url) == :link
    end

    test "returns video with a YouTube, Vimeo, or Twitch" do
      for url <- ~w(https://www.youtube.com/watch?v=dQw4w9WgXcQ https://vimeo.com/226379658 https://go.twitch.tv/videos/92287997) do
        assert UrlKit.get_type(url) == :video
      end
    end
  end

  describe "normalize_url" do
    test "defaults to nil" do
      assert UrlKit.normalize_url(nil) == nil
    end

    test "leaves 'normal' URLs alone" do
      url = "https://changelog.com/ohai-there"
      assert UrlKit.normalize_url(url) == url
    end

    test "removes UTM params" do
      url = "https://www.theverge.com/2017/11/7/16613234/next-level-ar-vr-memories-holograms-8i-actress-shoah-foundation?utm_campaign=theverge"
      normalized = "https://www.theverge.com/2017/11/7/16613234/next-level-ar-vr-memories-holograms-8i-actress-shoah-foundation"
      assert UrlKit.normalize_url(url) == normalized
    end
  end
end
