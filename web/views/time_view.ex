defmodule Changelog.TimeView do
  def duration(seconds) when is_nil(seconds), do: duration(0)
  def duration(seconds) when seconds < 3600 do
    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)
    "#{leading_zero(minutes)}:#{leading_zero(seconds)}"
  end
  def duration(seconds) when seconds >= 3600 do
    hours = div(seconds, 3600)
    remaining = rem(seconds, 3600)
    "#{hours}:#{duration(remaining)}"
  end

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

  defp leading_zero(integer) do
    if integer < 10 do
      "0#{integer}"
    else
      "#{integer}"
    end
  end
end
