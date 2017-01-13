defmodule Changelog.APIControllerTest do
  use Changelog.ConnCase

  describe "oembed" do
    test "with url of valid episode" do
      episode = insert(:published_episode)
      episode_url = "https://changelog.com/#{episode.podcast.slug}/#{episode.slug}"

      conn = get(build_conn(), "/api/oembed?url=#{episode_url}")

      assert conn.status == 200
      assert conn.resp_body =~ "iframe"
      assert conn.resp_body =~ episode.slug
    end

    test "with invalid url param" do
      assert_raise Ecto.NoResultsError, fn ->
        get(build_conn(), "/api/oembed?url=https://changelog.com")
      end
    end

    test "with no url param" do
      assert_raise Ecto.NoResultsError, fn ->
        get(build_conn(), "/api/oembed")
      end
    end
  end
end
