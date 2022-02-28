defmodule Changelog.Search do
  defmodule Page do
    defstruct entries: [], total_entries: 0, page_number: 0, total_pages: 1
  end

  alias Changelog.{Episode, NewsItem, Repo}
  # Algolia legacy plan allows 20 Kb for record size
  # Algolia does not count the size of the JSON payload the same as we do
  @margin 1024
  @byte_limit 20 * 1024 - @margin

  def search(query, opts \\ []) do
    case Algolia.search(namespace(), query, opts) do
      {:ok, response} ->
        results_from(response)

      _else ->
        results_from(%{})
    end
  end

  def search_with_highlights(query, opts \\ []) do
    case Algolia.search(namespace(), query, opts) do
      {:ok, response} ->
        results_with_highlights_from(response)

      _response ->
        results_with_highlights_from(%{})
    end
  end

  def save_item(%NewsItem{feed_only: true}), do: false

  def save_item(item = %NewsItem{status: :published}) do
    item
    |> to_records()
    |> Enum.with_index()
    |> Enum.each(fn {record, index} ->
      object_id = if index == 0, do: item.id, else: "#{item.id}-#{index}"
      result = Algolia.save_object(namespace(), record, object_id)

      case result do
        {:ok, _} ->
          result

        {:error, 400, msg} ->
          encoded = Jason.encode!(record)
          size = byte_size(encoded)
          IO.puts("Size: #{size}, Limit: #{@byte_limit}")
          raise "Algolia error, 400: #{msg}"

        other ->
          {:error, :other_error, other}
      end
    end)
  end

  def save_item(episode = %Episode{}) do
    episode
    |> Episode.get_news_item()
    |> save_item()
  end

  def save_item(_), do: false

  # Deprecated
  def update_item(item), do: save_item(item)

  def delete_item(item) do
    {:ok, _} = Algolia.delete_object(namespace(), item.id)
  end

  defp to_records(item = %NewsItem{type: :audio, object_id: _}) do
    item = NewsItem.load_object_with_transcript(item)
    record = item_to_record(item)
    records = transcript_to_records(item, item.object.transcript)
    [record | records]
  end

  defp to_records(item), do: [item_to_record(item)]

  defp item_to_record(item) do
    # Define keys, so we can figure out the byte-budget for our JSON payload
    keys = ["id", "headline", "story", "published_at"]

    {_, record, _} =
      start_record(keys)
      |> add_to_record("id", Integer.to_string(item.id))
      |> add_to_record("published_at", item.published_at)
      |> add_to_record("headline", item.headline)
      |> add_to_record("story", item.story, :cuttable)

    record
  end

  defp transcript_to_records(item, transcript) when is_list(transcript) do
    Enum.reduce(transcript, [], fn fragment, records ->
      case fragment do
        %{"title" => title, "body" => body} ->
          fragment_to_records(item, "#{title}: #{body}") ++ records

        _ ->
          records
      end
    end)
    |> Enum.reverse()
  end

  defp transcript_to_records(_, _), do: []

  defp fragment_to_records(item, text) do
    # Define keys, so we can figure out the byte-budget for our JSON payload
    keys = ["id", "published_at", "fragment"]

    if byte_size(text) > @byte_limit, do: raise("fragment too long")

    {_, record, _} =
      start_record(keys)
      |> add_to_record("id", Integer.to_string(item.id))
      |> add_to_record("published_at", item.published_at)
      |> add_to_record("fragment", text, :cuttable)

    [record]
  end

  defp results_from(response) do
    item_ids =
      response
      |> Map.get("hits", [])
      |> Enum.map(fn x -> Map.get(x, "id") end)
      |> Enum.map(&String.to_integer/1)

    items =
      NewsItem
      |> NewsItem.by_ids(item_ids)
      |> NewsItem.preload_all()
      |> Repo.all()
      |> Enum.map(&NewsItem.load_object/1)

    %Page{
      entries: items,
      total_pages: Map.get(response, "nbPages", 1),
      total_entries: Map.get(response, "nbHits", 0),
      page_number: Map.get(response, "page", 0)
    }
  end

  defp results_with_highlights_from(response) do
    hits = Map.get(response, "hits", [])

    item_ids =
      hits
      |> Enum.map(fn x -> Map.get(x, "id") end)
      |> Enum.map(&String.to_integer/1)

    highlights =
      hits
      |> Enum.map(fn x ->
        case Map.get(x, "_highlightResult", nil) do
          %{"fragment" => %{"value" => highlighted}} -> highlighted
          _ -> nil
        end
      end)

    items =
      NewsItem
      |> NewsItem.by_ids(item_ids)
      |> NewsItem.preload_all()
      |> Repo.all()
      |> Enum.map(&NewsItem.load_object/1)

    %Page{
      entries: Enum.zip(items, highlights),
      total_pages: Map.get(response, "nbPages", 1),
      total_entries: Map.get(response, "nbHits", 0),
      page_number: Map.get(response, "page", 0)
    }
  end

  defp namespace, do: "#{Mix.env()}_news_items"

  defp start_record(keys) do
    {get_byte_budget(keys), %{}, keys}
  end

  defp add_to_record({bytes_left, record, keys}, key, datetime = %DateTime{}) do
    if key not in keys do
      {:error, "unknown key"}
    end

    size = byte_size(Timex.format!(datetime, "{ISO:Extended}"))

    if size < bytes_left do
      {bytes_left - size, Map.put(record, key, datetime), keys}
    else
      {bytes_left, record, keys}
    end
  end

  defp add_to_record({bytes_left, record, keys}, key, text) do
    if key not in keys do
      {:error, "unknown key"}
    end

    text = clean(text)

    size = byte_size(text)

    if size < bytes_left do
      {bytes_left - size, Map.put(record, key, text), keys}
    else
      {bytes_left, record, keys}
    end
  end

  defp add_to_record({bytes_left, record, keys}, key, text, :cuttable) do
    if key not in keys do
      {:error, "unknown key"}
    end

    text =
      text
      |> clean()
      |> cut(bytes_left)

    size = byte_size(text)

    {bytes_left - size, Map.put(record, key, text), keys}
  end

  defp cut("", _), do: ""

  defp cut(text, byte_limit) do
    if byte_size(text) <= byte_limit do
      text
    else
      {keep, _} = String.split_at(text, -1)
      cut(keep, byte_limit)
    end
  end

  defp get_byte_budget(keys) do
    key_size =
      Enum.reduce(keys, 0, fn key, size ->
        size + byte_size(key)
      end)

    # Each key, has "":"" and all but one have ,
    json_syntax_size = byte_size("{}") + (length(keys) * 5 + (length(keys) - 1)) * byte_size(",")
    @byte_limit - key_size - json_syntax_size
  end

  defp clean(text) when is_binary(text) do
    Changelog.Emoji.remove(text)
  end

  defp clean(_), do: ""
end
