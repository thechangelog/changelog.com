defmodule Changelog.HtmlKit do
  def get_images(html) when is_nil(html), do: []

  def get_images(html) do
    Regex.scan(~r/<img.*?>/, html)
    |> List.flatten()
    |> Enum.map(&String.replace(&1, ~r/['\"]/, ""))
    |> Enum.map(&Regex.run(~r/src=(.*?)[\s|>]/, &1, capture: :all_but_first))
    |> List.flatten()
  end

  def get_title(html) when is_nil(html), do: ""
  def get_title(""), do: ""

  def get_title(html) do
    case Regex.named_captures(~r/<title.*?>(?<title>.*?)<\/title>/s, html) do
      %{"title" => title} ->
        title
        |> String.trim()
        |> String.split("\n")
        |> List.first()
        |> HtmlEntities.decode()

      _else ->
        "Couldn't parse title. Report to Jerod!"
    end
  end

  def put_a_rel(html, value) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        document
        |> Floki.attr("a", "rel", fn _ -> value end)
        |> Floki.raw_html()

      {:error, _string} ->
        html
    end
  end

  def put_img_width(html, width) when is_binary(width) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        document
        |> Floki.attr("img", "width", fn _ -> width end)
        |> Floki.raw_html()

      {:error, _string} ->
        html
    end
  end

  def put_img_width(html, width), do: put_img_width(html, Integer.to_string(width))

  def put_ugc({:safe, html}), do: put_ugc(html)

  def put_ugc(html), do: put_a_rel(html, "ugc")

  def put_sponsored({:safe, html}), do: put_sponsored(html)

  def put_sponsored(html), do: put_a_rel(html, "sponsored")

  def put_utm_source(html, value) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        document
        |> Floki.attr("a", "href", fn href ->
          merge_href_query_params(href, %{utm_source: value})
        end)
        |> Floki.raw_html(encode: false)

      {:error, _string} ->
        html
    end
  end

  defp merge_href_query_params(href, params) do
    uri = URI.parse(href)

    new_uri =
      cond do
        is_nil(uri.query) ->
          uri |> Map.put(:query, URI.encode_query(params))

        String.match?(uri.query, ~r/utm_/) ->
          uri

        true ->
          new_query = uri.query |> URI.decode_query() |> Map.merge(params)
          uri |> Map.put(:query, URI.encode_query(new_query))
      end

    URI.to_string(new_uri)
  end
end
