defmodule Changelog.UrlInspector do
  alias Changelog.NewsSource

  def get_source(url) when is_nil(url), do: nil
  def get_source(url) do
    NewsSource.get_by_url(url)
  end

  def get_title(url) when is_nil(url), do: nil
  def get_title(url) do
    case HTTPoison.get!(url, [], [follow_redirect: true, max_redirect: 5]) do
      %{status_code: 200, body: body} ->
        ~r/<title.*?>(?<title>.*)<\/title>/
        |> Regex.named_captures(body)
        |> Map.get("title")
      _else -> nil
    end
  end

  def get_type(url) when is_nil(url), do: :link
  def get_type(url) do
    cond do
      Enum.any?(project_regexes(), fn(r) -> Regex.match?(r, url) end) -> :project
      Enum.any?(video_regexes(), fn(r) -> Regex.match?(r, url) end) -> :video
      true -> :link
    end
  end

  defp project_regexes do
    [
      ~r/github\.com(?!\/blog)/,
      ~r/(?<!about\.)gitlab\.com/
    ]
  end

  defp video_regexes do
    [
      ~r/youtube\.com\/watch/,
      ~r/vimeo\.com\/\d+/,
      ~r/go\.twitch\.tv\/videos/
    ]
  end
end
