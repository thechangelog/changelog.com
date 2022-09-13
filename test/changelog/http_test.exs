defmodule Changelog.HTTPTest do
  use ExUnit.Case

  alias Changelog.HTTP

  test "we can make HTTP requests to AWS" do
    assert {:ok, _body} = HTTP.get("https://aws.amazon.com")
  end

  test "we can make HTTP requests to GitHub" do
    assert {:ok, _body} = HTTP.get("https://api.github.com")
  end
end
