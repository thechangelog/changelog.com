defmodule ChangelogWeb.TimeView do

  alias Timex.Duration

  def closest_monday_to(date) do
    offset = case Timex.weekday(date) do
      1 ->  0
      2 -> -1
      3 -> -2
      4 -> -3
      5 ->  3
      6 ->  2
      7 ->  1
    end

    Timex.shift(date, days: offset)
  end

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

  def hacker_date(ts) when is_nil(ts), do: ""
  def hacker_date(ts) when is_binary(ts) do
    {:ok, result} = Timex.parse(ts, "{YYYY}-{0M}-{0D} {h24}:{m}:{s}")
    hacker_date(result)
  end
  def hacker_date(ts) do
    {:ok, result} = Timex.format(ts, "{YYYY}-{0M}-{0D}")
    result
  end

  def hours_ago(hours) do
    Timex.subtract(Timex.now, Duration.from_hours(hours))
  end

  def hours_from_now(hours) do
    Timex.add(Timex.now, Duration.from_hours(hours))
  end

  def pretty_date(ts) when is_nil(ts), do: ""
  def pretty_date(ts) when is_binary(ts) do
    {:ok, result} = Timex.parse(ts, "{YYYY}-{0M}-{0D} {h24}:{m}:{s}")
    pretty_date(result)
  end
  def pretty_date(ts) do
    {:ok, result} = Timex.format(ts, "{Mshort} {D}, {YYYY}")
    result
  end

  def rounded_minutes(seconds) when is_nil(seconds), do: rounded_minutes(0)
  def rounded_minutes(seconds) do
    (seconds / 60) |> round
  end

  def rss(ts) when is_nil(ts), do: ""
  def rss(ts), do: ts |> format_to("{RFC1123}")

  def rfc3339(ts) when is_nil(ts), do: ""
  def rfc3339(ts), do: ts |> format_to("{RFC3339}")

  defp format_to(ts, format) do
    {:ok, result} = Timex.format(ts, format)
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

  def terse_date(ts) do
    {:ok, result} = Timex.format(ts, "{0M}/{0D}/{YY}")
    result
  end

  def time_is_url(nil), do: ""
  def time_is_url(ts), do: "https://time.is/#{DateTime.to_unix(ts)}"

  def ts(ts, style \\ "admin")
  def ts(ts, _style) when is_nil(ts), do: ""
  def ts(ts, style) do
    {:ok, formatted} = Timex.format(ts, "{ISO:Extended:Z}")
    {:safe, "<span class='time' data-style='#{style}'>#{formatted}</span>"}
  end

  def weeks(start_date \\ Timex.today, count \\ 8) do
    Timex.Interval.new(from: Timex.beginning_of_week(start_date), until: [weeks: count], step: [weeks: 1])
  end

  def week_start_end(date) do
    start_date = Timex.beginning_of_week(date)
    end_date = Timex.end_of_week(date)
    {:ok, pretty_start} = Timex.format(start_date, "{Mshort} {0D}")
    {:ok, pretty_end} = Timex.format(end_date, "{Mshort} {0D}")
    "#{pretty_start} - #{pretty_end}"
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
