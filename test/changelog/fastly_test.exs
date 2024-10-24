defmodule Changelog.FastlyTest do
	use ExUnit.Case

  import Mock

  alias Changelog.HTTP

  describe "purge/1" do
  	test "when given a url string" do
  		with_mock(HTTP, post: fn _, _, _ -> {:ok, %{status_code: 200, body: ""}} end) do
  			url = "https://cdn.changelog.com/uploads/podcast/1/the-changelog-1.mp3"
  			Changelog.Fastly.purge(url)
  			assert called(HTTP.post("https://api.fastly.com/purge/cdn.changelog.com/uploads/podcast/1/the-changelog-1.mp3", "", :_))
  		end
  	end
  end
end
