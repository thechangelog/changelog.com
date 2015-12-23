defmodule Changelog.Admin.PersonControllerTest do
  use Changelog.ConnCase
  alias Changelog.Person

  @valid_attrs %{name: "Joe Blow"}
  @invalid_attrs %{email: "noname@nope.com"}

  defp person_count(query), do: Repo.one(from p in query, select: count(p.id))

  test "lists all people on index" do
    p1 = insert_person()
    p2 = insert_person()

    conn = get conn, admin_person_path(conn, :index)

    assert html_response(conn, 200) =~ ~r/People/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  test "creates person and redirects" do
    conn = post conn, admin_person_path(conn, :create), person: @valid_attrs

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert person_count(Person) == 1
  end

  test "does not create with invalid attributes" do
    count_before = person_count(Person)
    conn = post conn, admin_person_path(conn, :create), person: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert person_count(Person) == count_before
  end
end
