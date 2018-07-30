defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias Changelog.{AdminPolicy, AdminsOnlyPolicy, NewsItemPolicy, PodcastPolicy, PersonPolicy, PostPolicy}
  alias ChangelogWeb.{Endpoint, PersonView}

  def canonical_url(conn), do: url(conn) <> conn.request_path
end
