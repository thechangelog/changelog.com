defmodule ChangelogWeb.Admin.ChannelController do
  use ChangelogWeb, :controller

  alias Changelog.Channel

  plug :scrub_params, "channel" when action in [:create, :update]

  def index(conn, params) do
    page =
      Channel
      |> order_by([c], asc: c.name)
      |> Repo.paginate(params)

    render(conn, :index, channels: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = Channel.admin_changeset(%Channel{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params = %{"channel" => channel_params}) do
    changeset = Channel.admin_changeset(%Channel{}, channel_params)

    case Repo.insert(changeset) do
      {:ok, channel} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(channel, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    channel = Repo.get!(Channel, id)
    changeset = Channel.admin_changeset(channel)
    render(conn, "edit.html", channel: channel, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "channel" => channel_params}) do
    channel = Repo.get!(Channel, id)
    changeset = Channel.admin_changeset(channel, channel_params)

    case Repo.update(changeset) do
      {:ok, channel} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(channel, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", channel: channel, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    channel = Repo.get!(Channel, id)
    Repo.delete!(channel)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_channel_path(conn, :index))
  end

  defp smart_redirect(conn, _channel, %{"close" => _true}) do
    redirect(conn, to: admin_channel_path(conn, :index))
  end
  defp smart_redirect(conn, channel, _params) do
    redirect(conn, to: admin_channel_path(conn, :edit, channel))
  end
end
