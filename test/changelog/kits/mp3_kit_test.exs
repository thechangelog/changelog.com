defmodule Changelog.Mp3KitTest do
  use ExUnit.Case

  import Changelog.TestCase

  alias Changelog.Mp3Kit

  describe "get_duration/1" do
    test "works when given a path to an mp3" do
      path = fixtures_path("/california.mp3")
      assert Mp3Kit.get_duration(path) == 179
    end

    test "works when directly given mp3 data" do
      {:ok, data} = File.read(fixtures_path("/california.mp3"))
      assert Mp3Kit.get_duration(data) == 179
    end
  end
end
