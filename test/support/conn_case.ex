defmodule ChangelogWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint ChangelogWeb.Endpoint

      use ChangelogWeb, :verified_routes

      alias Changelog.Repo
      alias ChangelogWeb.Router.Helpers, as: Routes

      # Import conveniences for testing with connections
      import Ecto
      import Ecto.Query, only: [from: 2]
      import Plug.Conn
      import Phoenix.ConnTest
      import Changelog.TestCase
      import Changelog.Factory
      import ChangelogWeb.TimeView, only: [hours_from_now: 1, hours_ago: 1]

      defp count(query), do: Repo.count(query)

      defp valid_xml(conn) do
        SweetXml.parse(conn.resp_body)
        true
      end

      defp assert_redirected_to(conn, expected_url) do
        actual_uri =
          conn
          |> Plug.Conn.get_resp_header("location")
          |> List.first()
          |> URI.parse()

        expected_uri = URI.parse(expected_url)

        assert conn.status == 302
        assert actual_uri.scheme == expected_uri.scheme
        assert actual_uri.host == expected_uri.host
        assert actual_uri.path == expected_uri.path

        if actual_uri.query do
          assert Map.equal?(
                   URI.decode_query(actual_uri.query),
                   URI.decode_query(expected_uri.query)
                 )
        end
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Changelog.Repo)

    Changelog.Cache.delete_all()

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Changelog.Repo, {:shared, self()})
    end

    user =
      cond do
        tags[:as_admin] -> Changelog.Factory.build(:person, admin: true)
        tags[:as_inserted_admin] -> Changelog.Factory.insert(:person, admin: true)
        tags[:as_editor] -> Changelog.Factory.build(:person, editor: true)
        tags[:as_inserted_editor] -> Changelog.Factory.insert(:person, editor: true)
        tags[:as_user] -> Changelog.Factory.build(:person, admin: false)
        tags[:as_inserted_user] -> Changelog.Factory.insert(:person, admin: false)
        tags[:as_inserted_member] -> Changelog.Factory.insert(:member)
        tags[:as_unapproved_user] -> Changelog.Factory.insert(:person, approved: false)
        true -> nil
      end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.assign(:current_user, user)

    {:ok, conn: conn, user: user}
  end
end
