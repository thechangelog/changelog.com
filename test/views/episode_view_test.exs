defmodule Changelog.EpisodeViewTest do
  use Changelog.ConnCase, async: true

  import Changelog.EpisodeView
  alias Changelog.Episode

  describe "audio_local_path" do
    test "is a path on the local file system with relative storage dir" do
      orig_env = Application.get_env(:arc, :storage_dir)
      Application.put_env(:arc, :storage_dir, "priv/static")
      episode = insert(:published_episode) |> stub_audio_file
      assert audio_local_path(episode) =~ ~r{^priv/static}
      Application.put_env(:arc, :storage_dir, orig_env)
    end

    test "is a path on the local file system with absolute storage dir" do
      orig_env = Application.get_env(:arc, :storage_dir)
      Application.put_env(:arc, :storage_dir, "/test")
      episode = insert(:published_episode) |> stub_audio_file
      assert audio_local_path(episode) =~ ~r{^/test/}
      Application.put_env(:arc, :storage_dir, orig_env)
    end
  end

  describe "audio_path" do
    test "is hard coded to california.mp3 when episode has no file" do
      episode = build(:episode)
      assert audio_path(episode) == "/california.mp3"
    end

    test "starts with the publicly served path when episode has file" do
      episode = insert(:published_episode) |> stub_audio_file
      assert audio_path(episode) =~ ~r{^/uploads/}
    end
  end

  test "megabytes" do
    assert megabytes(%Episode{bytes: 1000}) == 0
    assert megabytes(%Episode{bytes: 1_000_000}) == 1
    assert megabytes(%Episode{bytes: 68_530_176}) == 69
  end

  describe "number" do
    test "it is empty when slug is not a number" do
      assert number(build(:episode, slug: "not-a-number")) == nil
    end

    test "it is the slug when slug is a number" do
      assert number(build(:episode, slug: "211")) == "211"
    end
  end

  describe "numbered_title" do
    test "it has number but no pound by default when episode has number" do
      ep = build(:episode, slug: "1", title: "Test")
      assert numbered_title(ep) == "1: Test"
    end

    test "it includes a prefix passed in when episode has number" do
      ep = build(:episode, slug: "1", title: "Test")
      assert numbered_title(ep, "#") == "#1: Test"
    end

    test "it has just the episode title when episode has no number" do
      ep = build(:episode, slug: "bonus-ep", title: "Test")
      assert numbered_title(ep, "#") == "Test"
    end
  end
end
