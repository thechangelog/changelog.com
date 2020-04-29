defmodule ChangelogWeb.BenefitControllerTest do
  use ChangelogWeb.ConnCase

  test "renders the benefits sans details", %{conn: conn} do
    benefit = insert(:benefit, code: "ZOMG")
    conn = get(conn, Routes.benefit_path(conn, :index))
    assert conn.status == 200
    refute conn.resp_body =~ benefit.code
  end

  @tag :as_user
  test "renders the benefits with details", %{conn: conn} do
    benefit = insert(:benefit, code: "ZOMG")
    conn = get(conn, Routes.benefit_path(conn, :index))
    assert conn.status == 200
    assert conn.resp_body =~ benefit.code
  end
end
