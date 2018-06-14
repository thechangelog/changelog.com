defmodule ChangelogWeb.GithubControllerTest do
  use ChangelogWeb.ConnCase

  import Mock

  alias Changelog.{Github}

  describe "the event endpoint" do
    setup do
      conn = put_req_header(build_conn(), "accept", "application/json")
      {:ok, conn: conn}
    end

    test "it responds to the push event, calling the Transcript updater when repo is 'transcripts'", %{conn: conn} do
      with_mock(Github.Puller, [update: fn(_, _) -> true end]) do
        conn =
          conn
          |> put_req_header("x-github-event", "push")
          |> post(github_path(conn, :event), %{
              "repository" => %{"full_name" => "thechangelog/transcripts"},
              "commits" => [
                %{"id" => "1", "added" => ["jsparty/js-party-14.md"], "modified" => ["rfc/rfc-1.md"]},
                %{"id" => "2", "modified" => ["rfc/rfc-3.md", "podcast/podcast-1.md"]},
                %{"id" => "3", "added" => ["gotime/gotime-50.md"], "removed" => ["nope"]}
              ]
            })

        assert called Github.Puller.update("transcripts", ~w(jsparty/js-party-14.md rfc/rfc-1.md rfc/rfc-3.md podcast/podcast-1.md gotime/gotime-50.md))
        assert conn.status == 200
      end
    end

    test "it responds to the push event, calling the ShowNotes updater when repo is 'show-notes'", %{conn: conn} do
      with_mock(Github.Puller, [update: fn(_, _) -> true end]) do
        conn =
          conn
          |> put_req_header("x-github-event", "push")
          |> post(github_path(conn, :event), %{
              "repository" => %{"full_name" => "thechangelog/show-notes"},
              "commits" => [
                %{"id" => "1", "added" => ["jsparty/js-party-14.md"], "modified" => ["rfc/rfc-1.md"]},
                %{"id" => "2", "modified" => ["rfc/rfc-3.md", "podcast/podcast-1.md"]},
                %{"id" => "3", "added" => ["gotime/gotime-50.md"], "removed" => ["nope"]}
              ]
            })

        assert called Github.Puller.update("show-notes", ~w(jsparty/js-party-14.md rfc/rfc-1.md rfc/rfc-3.md podcast/podcast-1.md gotime/gotime-50.md))
        assert conn.status == 200
      end
    end

    test "it responds with method not allowed for push event when repo doesn't match", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-github-event", "push")
        |> post(github_path(conn, :event), %{
            "repository" => %{"full_name" => "thechangelog/changelog.com"},
            "commits" => [%{"id" => "1"}, %{"id" => "2"}, %{"id" => "3"}]
          })

      assert conn.status == 405
    end

    test "it responds with method not allowed for unsupported events", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-github-event", "milestone")
        |> post(github_path(conn, :event), %{})

      assert conn.status == 405
    end
  end
end
