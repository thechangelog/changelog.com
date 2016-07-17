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

  def pretty_date(ts) when is_nil(ts), do: ""
  def pretty_date(ts) do
    {:ok, result} =
      ts
      |> Changelog.Timex.from_ecto
      |> Timex.format("{Mshort} {D} {YYYY}")
    result
  end

  def rss(ts) when is_nil(ts), do: ""
  def rss(ts) do
    {:ok, result} =
      ts
      |> Changelog.Timex.from_ecto
      |> Timex.format("{RFC1123}")
    result
  end

  def seconds(duration) when not is_binary(duration), do: seconds("00")
  def seconds(duration) do
    case String.split(duration, ":") do
      [h, m, s] -> to_seconds(:hours, h) + to_seconds(:minutes, m) + to_seconds(s)
      [m, s] -> to_seconds(:minutes, m) + to_seconds(s)
      [s] -> to_seconds(s)
      _ -> 0
    end
  end

  defp to_seconds(:hours, str), do: string_to_rounded_integer(str) * 3600
  defp to_seconds(:minutes, str), do: string_to_rounded_integer(str) * 60
  defp to_seconds(str), do: string_to_rounded_integer(str)

  defp string_to_rounded_integer(str) do
    if String.contains?(str, ".") do
      round(String.to_float(str))
    else
      String.to_integer(str)
    end
  end

  defp leading_zero(integer) do
    if integer < 10 do
      "0#{integer}"
    else
      "#{integer}"
    end
  end
end
