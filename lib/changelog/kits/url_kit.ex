defmodule Changelog.UrlKit do
  alias Changelog.{NewsSource, Regexp}

  def get_html(nil), do: ""
  def get_html(url) do
    try do
      case HTTPoison.get!(url, [], [follow_redirect: true, max_redirect: 5]) do
        %{status_code: 200, headers: headers, body: body} ->
          case List.keyfind(headers, "Content-Encoding", 0) do
            {"Content-Encoding", "gzip"} -> :zlib.gunzip(body)
            {"Content-Encoding", "x-gzip"} -> :zlib.gunzip(body)
            _else -> body
          end
        _else -> ""
      end
    rescue
      HTTPoison.Error -> ""
    end
  end

  def get_object_id(type, url) when is_nil(type) or is_nil(url), do: nil
  def get_object_id(type, url) when is_binary(type), do: get_object_id(String.to_existing_atom(type), url)
  def get_object_id(_type, url) do
    if is_self_hosted(url) do
      String.split(url, "/") |> Enum.take(-2) |> Enum.join(":")
    else
      nil
    end
  end

  def get_source(nil), do: nil
  def get_source(url) do
    NewsSource.get_by_url(url)
  end

  def get_type(nil), do: :link
  def get_type(url) do
    cond do
      Enum.any?(project_regexes(), fn(r) -> Regex.match?(r, url) end) -> :project
      Enum.any?(video_regexes(), fn(r) -> Regex.match?(r, url) end) -> :video
      true -> :link
    end
  end

  def get_youtube_id(url) do
    cond do
      String.match?(url, List.first(youtube_regexes())) ->
        URI.parse(url)
        |> Map.get(:query)
        |> URI.decode_query()
        |> Map.get("v")
      String.match?(url, List.last(youtube_regexes())) ->
        url
        |> String.split("/")
        |> List.last
      true -> nil
    end
  end

  def is_youtube(nil), do: false
  def is_youtube(url) do
    Enum.any?(youtube_regexes(), &(String.match?(url, &1)))
  end

  def normalize_url(nil), do: nil
  def normalize_url(url) do
    parsed = URI.parse(url)
    query = normalize_query_string(parsed.query)

    parsed
    |> Map.put(:query, query)
    |> URI.to_string()
  end

  def sans_scheme(nil), do: nil
  def sans_scheme(url), do: String.replace(url, Regexp.http(), "")

  defp is_self_hosted(url), do: String.contains?(url, "changelog.com")

  defp normalize_query_string(nil), do: nil
  defp normalize_query_string(query) do
    normalized =
      query
      |> URI.decode_query()
      |> Map.drop(~w(utm_source utm_campaign utm_medium utm_term utm_content))
      |> URI.encode_query()

    if String.length(normalized) == 0 do
      nil
    else
      normalized
    end
  end

  defp project_regexes do
    [
      ~r/github\.com(?!\/blog)/,
      ~r/(?<!about\.)gitlab\.com/
    ]
  end

  defp video_regexes do
    youtube_regexes() ++ [~r/vimeo\.com\/\d+/, ~r/go\.twitch\.tv\/videos/]
  end

  defp youtube_regexes do
    [~r/youtube\.com\/watch/, ~r/youtu\.be/]
  end
end
