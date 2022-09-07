defmodule Changelog.FileKitTest do
  use ExUnit.Case
  import Changelog.TestCase
  alias Changelog.FileKit

  describe "get_type/1" do
    test "detects a gif by its magic number" do
      file = fixtures_path("/images/this-is-a-gif")
      assert :gif == FileKit.get_type(file)
    end

    test "detects an svg by its magic number" do
      file = fixtures_path("/images/this-is-an-svg")
      assert :svg == FileKit.get_type(file)
    end

    test "detects a png by its file extension" do
      file = fixtures_path("/images/avatar600x600.png")
      assert :png == FileKit.get_type(file)
    end

    test "detects a jpg by its file extension" do
      file = "test.jpg"
      assert :jpg == FileKit.get_type(file)
    end

    test "prefers binary data when provided" do
      data = File.read!(fixtures_path("/images/this-is-a-gif"))
      map = %{file_name: "test.jpg", binary: data}
      assert :gif == FileKit.get_type(map)
    end

    test "falls back to file name when binary errors" do
      map = %{file_name: "test.jpg", binary: fixtures_path("/images/this-is-not-real")}
      assert :jpg == FileKit.get_type(map)
    end

    test "reads and prefers binary data when path provided" do
      map = %{file_name: "test.jpg", path: fixtures_path("/images/this-is-a-gif")}
      assert :gif == FileKit.get_type(map)
    end

    test "works with just file name when on it is provided" do
      map = %{file_name: "test.jpg"}
      assert :jpg == FileKit.get_type(map)
    end
  end
end
