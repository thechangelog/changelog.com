defmodule ChangelogWeb.Meta.CanonicalUrl do
  alias ChangelogWeb.PostView

  def canonical_url(assigns), do: get(assigns)

  defp get(%{view_module: PostView, post: %{canonical_url: url}}) when is_binary(url), do: url
  defp get(_), do: nil
end
