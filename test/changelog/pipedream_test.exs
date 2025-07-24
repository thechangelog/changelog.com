defmodule Changelog.PipedreamTest do
  use ExUnit.Case

  import Mock

  alias Changelog.HTTP

  describe "purge/1" do
    test "when given a url string" do
      with_mocks([
        {Changelog.Dns, [], [aaaa: fn _ -> {:ok, ["first.machine", "second.machine"]} end]},
        {HTTP, [], [request: fn _, _, _, _ -> {:ok, %{status_code: 200, body: ""}} end]}
      ]) do
        url = "https://cdn.changelog.com/uploads/podcast/1/the-changelog-1.mp3"

        Changelog.Pipedream.purge(url)

        assert called(Changelog.Dns.aaaa(:_))

        assert called(
                 HTTP.request(
                   :purge,
                   "http://first.machine:9000/uploads/podcast/1/the-changelog-1.mp3",
                   "",
                   [{"Host", "cdn.changelog.com"}]
                 )
               )

        assert called(
                 HTTP.request(
                   :purge,
                   "http://second.machine:9000/uploads/podcast/1/the-changelog-1.mp3",
                   "",
                   [{"Host", "cdn.changelog.com"}]
                 )
               )
      end
    end

    test "when an instance fails to purge" do
      with_mocks([
        {Changelog.Dns, [], [aaaa: fn _ -> {:ok, ["first.machine"]} end]},
        {HTTP, [], [request: fn _, _, _, _ -> {:error, %{status_code: 503, body: ""}} end]},
        {Sentry, [], [capture_message: fn _, _ -> {:ok} end]}
      ]) do
        url = "https://cdn.changelog.com/uploads/podcast/1/the-changelog-1.mp3"

        Changelog.Pipedream.purge(url)

        assert called(Changelog.Dns.aaaa(:_))

        assert called(
                 HTTP.request(
                   :purge,
                   "http://first.machine:9000/uploads/podcast/1/the-changelog-1.mp3",
                   "",
                   [{"Host", "cdn.changelog.com"}]
                 )
               )

        assert called(Sentry.capture_message(:_, :_))
      end
    end

    test "when an instance returns non-200 status code" do
      with_mocks([
        {Changelog.Dns, [], [aaaa: fn _ -> {:ok, ["first.machine"]} end]},
        {HTTP, [], [request: fn _, _, _, _ -> {:ok, %{status_code: 404, body: "Not Found"}} end]},
        {Sentry, [], [capture_message: fn _, _ -> {:ok} end]}
      ]) do
        url = "https://cdn.changelog.com/uploads/podcast/1/the-changelog-1.mp3"

        Changelog.Pipedream.purge(url)

        assert called(Changelog.Dns.aaaa(:_))

        assert called(
                 HTTP.request(
                   :purge,
                   "http://first.machine:9000/uploads/podcast/1/the-changelog-1.mp3",
                   "",
                   [{"Host", "cdn.changelog.com"}]
                 )
               )

        assert called(Sentry.capture_message(:_, :_))
      end
    end

    test "when DNS fails" do
      with_mocks([
        {Changelog.Dns, [], [aaaa: fn _ -> {:error, :not_found} end]},
        {HTTP, [], [request: fn _, _, _, _ -> {:ok, %{status_code: 200, body: ""}} end]},
        {Sentry, [], [capture_message: fn _, _ -> {:ok} end]}
      ]) do
        url = "https://cdn.changelog.com/uploads/podcast/1/the-changelog-1.mp3"

        Changelog.Pipedream.purge(url)

        assert called(Changelog.Dns.aaaa(:_))
        assert called(Sentry.capture_message(:_, :_))
        refute called(HTTP.request(:purge, :_, :_, :_))
      end
    end
  end
end
