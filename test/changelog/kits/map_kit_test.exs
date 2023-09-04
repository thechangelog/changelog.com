defmodule Changelog.MapKitTest do
  use ExUnit.Case

  alias Changelog.MapKit

  describe "sans_blanks/1" do
    test "returns a map that removes blank values" do
      map = %{"name" => "", "email" => nil, "ohai" => "yes"}

      assert MapKit.sans_blanks(map) == %{"ohai" => "yes"}
    end
  end
end
