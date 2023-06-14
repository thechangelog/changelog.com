defmodule ChangelogWeb.MetacastView do
  use ChangelogWeb, :public_view

  alias Changelog.Files.Cover

  def cover_url(metacast), do: cover_url(metacast, :original)

  def cover_url(metacast, version) do
    if metacast.cover do
      Cover.url({metacast.cover, metacast}, version)
    else
      url(~p"/images/defaults/black.png")
    end
  end
end
