defmodule Changelog.SlackControllerTest do
  use Changelog.ConnCase

  describe "the gotime robot" do
    test "it responds with canned message for now" do
      conn = get(build_conn, slack_path(build_conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "soon"
    end
  end
end
