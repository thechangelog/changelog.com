defmodule Changelog.TimeView do
  def rss(ts) when is_nil(ts), do: ""
  def rss(ts) do
    {:ok, result} =
      ts
      |> Changelog.Timex.from_ecto
      |> Timex.format("{RFC822}")
    result
  end

  def terse(ts) when is_nil(ts), do: ""
  def terse(ts) do
    {:ok, result} = ts
      |> Changelog.Timex.from_ecto
      |> Timex.format("{M}/{D}/{YY} – {h12}:{m}{AM} ({Zname})")
    result
  end
end
