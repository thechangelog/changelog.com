defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias Changelog.{Podcast, Repo}
  alias ChangelogWeb.{Endpoint, PersonView}

  def canonical_url(conn), do: url(conn) <> conn.request_path

  def footer_podcasts do
    Podcast.active
    |> Podcast.oldest_first
    |> Repo.all
  end
end
