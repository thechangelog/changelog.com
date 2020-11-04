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

  def put_ugc({:safe, html}), do: put_ugc(html)

  def put_ugc(html), do: put_a_rel(html, "ugc")

  def put_sponsored({:safe, html}), do: put_sponsored(html)

  def put_sponsored(html), do: put_a_rel(html, "sponsored")
end
