defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Apple, CanonicalUrl, Description, Feeds,
                            Image, Title, Twitter}

  alias ChangelogWeb.{Endpoint, PersonView}
end
