defmodule Changelog.TypesenseSearch do
  require Logger

  defmodule Page do
    defstruct entries: [], total_entries: 0, page_number: 0, total_pages: 1
  end

  alias Changelog.{Episode, NewsItem, Repo, Typesense}
  # We limit record size to improve relevancy
  @margin 1024
  @byte_limit 20 * 1024 - @margin

  def create_collection() do
    # If the schema needs to be changed,
    #   it's best to clone the current collection via the Typesense Cloud UI (which will copy over synonyms and curation rules)
    #   and then update the schema by dropping/adding fields.
    # The following is mainly for bootstrapping the initial collection, and storing the schema in version control for posterity.
    Typesense.Client.create_collection(%{
      name: namespace(),
      fields: [
        %{name: "headline", type: "string", optional: true},
        %{name: "story", type: "string", optional: true},
        %{name: "fragment", type: "string", optional: true},
        %{name: "item_id", type: "int64", facet: true, optional: true},
        %{name: "published_at", type: "int64", optional: true}
      ],
      token_separators: ["(", ")", "[", "]", "/", "<", ">"]
    })
  end

  def search(opts \\ []) do
    case Typesense.Client.search(namespace(), opts) do
      {:ok, response} ->
        results_from(response)

      response ->
        Logger.error("Error during search: #{inspect(opts)}. Response: #{inspect(response)}")
        results_from(%{})
    end
  end

  def search_with_highlights(opts \\ []) do
    case Typesense.Client.search(namespace(), opts) do
      {:ok, response} ->
        results_with_highlights_from(response)

      response ->
        Logger.error("Error during search: #{inspect(opts)}. Response: #{inspect(response)}")
        results_with_highlights_from(%{})
    end
  end

  def save_items(items) do
    records =
      items
      |> Enum.filter(fn item -> item.feed_only != true && item.status == :published end)
      |> Enum.map(fn item -> to_records(item) end)
      |> Enum.map(fn item_records ->
        Enum.with_index(item_records)
        |> Enum.map(fn {record, index} ->
          Map.put(record, "id", (if index == 0, do: "#{record["item_id"]}", else: "#{record["item_id"]}-#{index}"))
        end)
      end)
      |> List.flatten()

    # Logger.debug(inspect(records, limit: :infinity))
    result = Typesense.Client.upsert_documents(namespace(), records)

    case result do
      {:ok, response} ->
        %HTTPoison.Response{body: body} = response

        failed_items =
          body
          |> String.split("\n")
          |> Enum.map(fn row -> Jason.decode!(row) end)
          |> Enum.filter(fn row -> row["success"] == false end)

        if length(failed_items) > 0 do
          Logger.error("Error importing items: #{inspect(failed_items)}")
          {:error, :import_failed, failed_items}
        else
          {:ok}
        end

      other ->
        Logger.error("Could not upsert documents into Typesense: #{inspect(result)}}")
        {:error, :other_error, other}
    end
  end

  def save_item(%NewsItem{feed_only: true}), do: false

  def save_item(item = %NewsItem{status: :published}) do
    save_items([item])
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
    case Typesense.Client.delete_document(namespace(), item.id) do
      {:ok, _response} -> :ok
      {:error, _response} ->
        Logger.error("Typesense: could not delete item #{item.id}")
        :ok
    end
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
    keys = ["item_id", "headline", "story", "published_at"]

    {_, record, _} =
      start_record(keys)
      |> add_to_record("item_id", item.id)
      |> add_to_record("published_at", DateTime.to_unix(item.published_at))
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
    keys = ["item_id", "published_at", "fragment"]

    if byte_size(text) > @byte_limit, do: raise("fragment too long")

    {_, record, _} =
      start_record(keys)
      |> add_to_record("item_id", item.id)
      |> add_to_record("published_at", DateTime.to_unix(item.published_at))
      |> add_to_record("fragment", text, :cuttable)

    [record]
  end

  defp results_from(response) do
    hits = hits_from_response(response)

    item_ids =
      hits
      |> Enum.map(fn x -> Map.get(x, "document") end)
      |> Enum.map(fn x -> Map.get(x, "item_id") end)

    items =
      NewsItem
      |> NewsItem.by_ids(item_ids)
      |> NewsItem.preload_all()
      |> Repo.all()
      |> Enum.map(&NewsItem.load_object/1)

    %Page{
      entries: items,
      total_pages: Map.get(response, "found", 0) / get_in(response, [Access.key("request_params", %{}), Access.key("per_page", 1)]) |> Float.ceil(),
      total_entries: Map.get(response, "found", 0),
      page_number: Map.get(response, "page", 1)
    }
  end

  defp results_with_highlights_from(response) do
    # Logger.debug(inspect(response, limit: :infinity))

    hits = hits_from_response(response)

    item_ids =
      hits
      |> Enum.map(fn x -> Map.get(x, "document") end)
      |> Enum.map(fn x -> Map.get(x, "item_id") end)

    highlights =
      hits
      |> Enum.map(fn x ->
        case Map.get(x, "highlight", nil) do
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
      total_pages: Map.get(response, "found", 0) / get_in(response, [Access.key("request_params", %{}), Access.key("per_page", 1)]) |> Float.ceil(),
      total_entries: Map.get(response, "found", 0),
      page_number: Map.get(response, "page", 1)
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

    size = if is_number(text) do
            text |> :binary.encode_unsigned |> byte_size
          else
            byte_size(text)
          end

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

  defp hits_from_response(%{"grouped_hits" => grouped_hits}) do
    grouped_hits
    |> Enum.map(fn grouped_hit -> grouped_hit["hits"] end )
    |> List.flatten
  end

  defp hits_from_response(%{"hits" => hits}) do
    hits
  end

  defp clean(text) when is_binary(text) do
    Changelog.Emoji.remove(text)
  end

  defp clean(text) when is_number(text), do: text

  defp clean(_), do: ""
end
