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

  # test "creates user video and redirects" do
  #   conn = post conn, video_path(conn, :create), video: @valid_attrs

  #   assert redirected_to(conn) == video_path(conn, :index)
  #   assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  # end

  # test "does not create with invalid attributes", %{conn: conn, user: _user} do
  #   count_before = video_count(Video)
  #   conn = post conn, video_path(conn, :create), video: @invalid_attrs

  #   assert html_response(conn, 200) =~ ~r/errors/
  #   assert video_count(Video) == count_before
  # end
end
