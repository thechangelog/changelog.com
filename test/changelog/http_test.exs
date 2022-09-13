defmodule Changelog.HTTPTest do
  use ExUnit.Case

  alias Changelog.HTTP

  test "we can make HTTP requests to AWS" do
    assert {:ok, _body} = HTTP.get("https://aws.amazon.com")
    assert %{body: _} = HTTP.get!("https://aws.amazon.com")
  end

  test "we can make HTTP requests to GitHub" do
    assert {:ok, _body} = HTTP.get("https://api.github.com")
    assert %{body: _} = HTTP.get!("https://api.github.com")
  end

  test "we can make HTTP requests to cdn.changelog.com" do
    assert {:ok, _body} = HTTP.get("https://cdn.changelog.com")
    assert %{body: _} = HTTP.get!("https://cdn.changelog.com")
  end
end
