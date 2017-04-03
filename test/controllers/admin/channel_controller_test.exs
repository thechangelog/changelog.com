defmodule Changelog.Admin.ChannelControllerTest do
  use Changelog.ConnCase

  alias Changelog.Channel

  @valid_attrs %{name: "Ruby on Rails", slug: "ruby-on-rails"}
  @invalid_attrs %{name: "Ruby on Rails", slug: ""}

  @tag :as_admin
  test "lists all channels", %{conn: conn} do
    t1 = insert(:channel)
    t2 = insert(:channel)

    conn = get(conn, admin_channel_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Channels/
    assert String.contains?(conn.resp_body, t1.name)
    assert String.contains?(conn.resp_body, t2.name)
  end

  @tag :as_admin
  test "renders form to create new channel", %{conn: conn} do
    conn = get(conn, admin_channel_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates channel and smart redirects", %{conn: conn} do
    conn = post(conn, admin_channel_path(conn, :create), channel: @valid_attrs, close: true)

    assert redirected_to(conn) == admin_channel_path(conn, :index)
    assert count(Channel) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Channel)
    conn = post(conn, admin_channel_path(conn, :create), channel: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Channel) == count_before
  end

  @tag :as_admin
  test "renders form to edit channel", %{conn: conn} do
    channel = insert(:channel)

    conn = get(conn, admin_channel_path(conn, :edit, channel))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates channel and smart redirects", %{conn: conn} do
    channel = insert(:channel)

    conn = put(conn, admin_channel_path(conn, :update, channel.id), channel: @valid_attrs)

    assert redirected_to(conn) == admin_channel_path(conn, :edit, channel)
    assert count(Channel) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    channel = insert(:channel)
    count_before = count(Channel)

    conn = put(conn, admin_channel_path(conn, :update, channel.id), channel: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Channel) == count_before
  end

  test "requires user auth on all actions", %{conn: conn} do
    Enum.each([
      get(conn, admin_channel_path(conn, :index)),
      get(conn, admin_channel_path(conn, :new)),
      post(conn, admin_channel_path(conn, :create), channel: @valid_attrs),
      get(conn, admin_channel_path(conn, :edit, "123")),
      put(conn, admin_channel_path(conn, :update, "123"), channel: @valid_attrs),
      delete(conn, admin_channel_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
