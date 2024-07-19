defmodule ChangelogWeb.Xml.Chapters do
  alias Changelog.MapKit

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document(chapters, namespace \\ nil) do
    chapters
    |> chapters(namespace)
    |> XmlBuilder.document()
  end

  def chapters(chapters, namespace \\ nil) do
    {
      with_namespace("chapters", namespace),
      %{version: "1.1", xmlns: "http://podlove.org/simple-chapters"},
      Enum.map(chapters, fn c -> chapter(c, namespace) end)
    }
  end

  defp chapter(chapter, namespace) do
    {
      with_namespace("chapter", namespace),
      %{
        start: round(chapter.starts_at),
        title: chapter.title,
        href: chapter.link_url,
        image: chapter.image_url
      }
      |> MapKit.sans_blanks()
    }
  end

  defp with_namespace(name, nil), do: name

  defp with_namespace(name, namespace) do
    "#{namespace}:#{name}"
  end
end
