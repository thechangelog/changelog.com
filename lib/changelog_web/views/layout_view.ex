defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias ChangelogWeb.{Endpoint, PersonView}

  def canonical_url(conn), do: url(conn) <> conn.request_path

  def footer_podcasts do
    [
      %{name: "The Changelog", slug: "podcast"},
      %{name: "JS Party", slug: "jsparty"},
      %{name: "Founders Talk", slug: "founderstalk"},
      %{name: "Away From Keyboard", slug: "afk"},
      %{name: "Practical AI", slug: "practicalai"},
      %{name: "Go Time", slug: "gotime"},
      %{name: "Spotlight", slug: "spotlight"}
    ]
  end
end
