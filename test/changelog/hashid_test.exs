defmodule Changelog.HashidTest do
  use ExUnit.Case

  test "encode/decode a single id returns single id" do
    encoded = Changelog.Hashid.encode 8675309
    assert Changelog.Hashid.decode(encoded) == 8675309
  end

  test "encode/decode list of ids returns list of ids" do
    encoded = Changelog.Hashid.encode [8, 6, 7]
    assert Changelog.Hashid.decode(encoded) == [8, 6, 7]
  end
end
