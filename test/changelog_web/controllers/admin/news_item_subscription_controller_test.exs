defmodule ChangelogWeb.Admin.NewsItemSubscriptionControllerTest do
  use ChangelogWeb.ConnCase

  @tag :as_admin
  test "lists all subs on index", %{conn: conn} do
    item = insert(:published_news_item)
    p1 = insert(:person)
    p2 = insert(:person)
    insert(:subscription_on_item, item: item, person: p1)
    insert(:subscription_on_item, item: item, person: p2)

    conn = get(conn, Routes.admin_news_item_subscription_path(conn, :index, item))

    assert html_response(conn, 200) =~ ~r/Subscriptions/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  test "requires user auth on all actions", %{conn: conn} do
    item = insert(:news_item)
    insert(:subscription_on_item, item: item)

    Enum.each(
      [
        get(conn, Routes.admin_news_item_subscription_path(conn, :index, item))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
