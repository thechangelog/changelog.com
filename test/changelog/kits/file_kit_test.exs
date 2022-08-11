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
  end
end
