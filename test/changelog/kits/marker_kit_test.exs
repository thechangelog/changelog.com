defmodule Changelog.MarkerKitTest do
  use ExUnit.Case
  import Changelog.TestCase
  alias Changelog.Kits.MarkerKit

  describe "to_youtube/1" do
    test "works for News 127" do
      [csv, desired] =
        "/markers/news-127.csv"
        |> fixtures_path()
        |> File.read!()
        |> String.split("---")

      assert MarkerKit.to_youtube(csv) == String.trim(desired)
    end

    test "works for Iterviews 624" do
      [csv, desired] =
        "/markers/interviews-624.csv"
        |> fixtures_path()
        |> File.read!()
        |> String.split("---")

      assert MarkerKit.to_youtube(csv) == String.trim(desired)
    end

    test "works for Iterviews 625" do
      [csv, desired] =
        "/markers/interviews-625.csv"
        |> fixtures_path()
        |> File.read!()
        |> String.split("---")

      assert MarkerKit.to_youtube(csv) == String.trim(desired)
    end
  end
end
