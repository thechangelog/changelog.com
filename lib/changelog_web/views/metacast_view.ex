defmodule ChangelogWeb.MetacastView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{Endpoint}
  alias Changelog.Files.Cover

  def cover_path(metacast, version) do
    {metacast.cover, metacast}
    |> Cover.url(version)
    |> String.replace_leading("/priv", "")
  end

  def cover_local_path(metacast) do
    path =
      metacast
      |> cover_path(:original)
      |> String.split("?")
      |> List.first()

    waffle_dir = Application.get_env(:waffle, :storage_dir)

    if String.starts_with?(path, waffle_dir) do
      path
    else
      Application.app_dir(:changelog, "priv#{path}")
    end
  end

  def cover_url(metacast), do: cover_url(metacast, :original)

  def cover_url(metacast, version) do
    if metacast.cover do
      Routes.static_url(Endpoint, cover_path(metacast, version))
    else
      "/images/defaults/black.png"
    end
  end
end
