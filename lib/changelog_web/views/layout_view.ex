defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias ChangelogWeb.{Endpoint, PersonView}

  def canonical_url(conn), do: url(conn) <> conn.request_path

  def footer_podcasts do
    [
      %{name: "The Changelog", slug: "podcast"},
      %{name: "Go Time", slug: "gotime"},
      %{name: "JS Party", slug: "jsparty"},
      %{name: "Practical AI", slug: "practicalai"},
      %{name: "Founders Talk", slug: "founderstalk"},
      %{name: "Request For Commits", slug: "rfc"},
    ]
  end
end
