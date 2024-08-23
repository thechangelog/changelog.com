defmodule Changelog.Social.SocialTest do
  use Changelog.SchemaCase

  import Mock

  alias Changelog.Social

  describe "post/1" do
    test "creates a status with applicable data" do
      podcast = insert(:podcast, mastodon_token: "12345")
      episode = insert(:published_episode, podcast: podcast)

      with_mock(Social.Client, create_status: fn _, _ -> {:ok, %{body: %{"url" => "https://test.com"}}} end) do
        Social.post(episode)

        assert called(Social.Client.create_status("12345", :_))
        assert Repo.get(Changelog.Episode, episode.id).socialize_url == "https://test.com"
      end
    end
  end

  describe "description/1" do
    test "replaces nothing when no hosts or guests" do
      episode = insert(:episode, summary: "Jerod interviews Uncle Buck & Buck Cherry about some cool stuff")

      assert Social.description(episode) == episode.summary
    end

    test "replaces referenced names with mastodon handles" do
      host1 = insert(:person, name: "Jerod Santo", mastodon_handle: "jerod@changelog.social")
      host2 = insert(:person, name: "Adam Stac", mastodon_handle: nil)
      host3 = insert(:person, name: "Gerhard Lazu", mastodon_handle: "gerhard@lazu.ch")
      guest1 = insert(:person, name: "Uncle Buck", mastodon_handle: "")
      guest2 = insert(:person, name: "Buck Cherry", mastodon_handle: "buck@mastodon.social")

      episode = insert(:episode, summary: "Jerod, Gerhard Lazu & Adam Stac interviews Uncle Buck & Buck Cherry about some cool stuff")

      insert(:episode_host, episode: episode, person: host1)
      insert(:episode_host, episode: episode, person: host2)
      insert(:episode_host, episode: episode, person: host3)
      insert(:episode_guest, episode: episode, person: guest1)
      insert(:episode_guest, episode: episode, person: guest2)

      expected = "@jerod@changelog.social, @gerhard@lazu.ch & Adam Stac interviews Uncle Buck & @buck@mastodon.social about some cool stuff"

      assert Social.description(episode) == expected
    end
  end
end
