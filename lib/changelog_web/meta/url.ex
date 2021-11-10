defmodule ChangelogWeb.Meta.Url do
  alias ChangelogWeb.{Meta, PostView}

  def get(type, conn) do
    assigns = Meta.prep_assigns(conn)

    case type do
      :canonical -> canonical(assigns)
    end
  end

  defp canonical(%{view_module: PostView, post: %{canonical_url: url}}) when is_binary(url), do: url
  defp canonical(_), do: nil
end
