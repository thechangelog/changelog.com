defmodule Changelog.Icecast do
  defmodule Stats do
    @derive Jason.Encoder
    defstruct type: :icecast, streaming: false, listeners: 0
  end

  def host, do: "http://45.79.19.10:8000"

  def live_url, do: "#{host()}/stream"

  def is_streaming do
    stats = get_stats()
    stats.streaming
  end

  def stats_url, do: "#{host()}/status-json.xsl"

  def get_stats do
    try do
      stats_url()
      |> HTTPoison.get!()
      |> Map.get(:body)
      |> Jason.decode!()
      |> get_in(["icestats", "source"])
      |> source_stats()
    rescue
      HTTPoison.Error    -> %Stats{}
      Jason.DecodeError -> %Stats{}
    end
  end

  defp source_stats(nil), do: %Stats{}
  defp source_stats(source), do: %Stats{streaming: true, listeners: source["listeners"]}
end
