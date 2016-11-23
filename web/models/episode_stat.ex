defmodule Changelog.EpisodeStat do
  use Changelog.Web, :model

  schema "episode_stats" do
    field :date, Timex.Ecto.Date
    field :episode_bytes, :integer
    field :total_bytes, :integer
    field :downloads, :float
    field :uniques, :integer
    field :demographics, :map

    belongs_to :episode, Changelog.Episode
    belongs_to :podcast, Changelog.Podcast
    timestamps
  end

  def newest_first(query, field \\ :date) do
    from e in query, order_by: [desc: ^field]
  end

  def changeset(episode_stat, params \\ %{}) do
    episode_stat
    |> cast(params, ~w(date episode_id podcast_id episode_bytes total_bytes downloads uniques demographics))
    |> validate_required([:date, :episode_id, :podcast_id])
  end

  def downloads_by_browser(stats) when is_list(stats) do
    stats
    |> Enum.map(&(Map.get(&1.demographics, "agents")))
    |> Enum.map(fn(agents) ->
      agents
      |> browsers_agents_only
      |> group_agents_by(fn(agent) ->
        case UserAgentParser.detect_browser(agent) do
          %UA.Browser{family: family} -> family
          :unknown -> "Unknown"
        end
      end)
    end)
    |> downloads_list_merged_and_sorted
  end
  def downloads_by_browser(stat), do: downloads_by_browser([stat])

  def downloads_by_client(stats) when is_list(stats) do
    stats
    |> Enum.map(&(Map.get(&1.demographics, "agents")))
    |> Enum.map(fn(agents) ->
      Enum.reduce(agents, %{}, fn({agent, downloads}, acc) ->
        # the 'client' is the section of the user agent prior to a '/'
        key = List.first(String.split(agent, "/"))
        Map.update(acc, key, downloads, &(&1 + downloads))
      end)
    end)
    |> downloads_list_merged_and_sorted
  end
  def downloads_by_client(stat), do: downloads_by_client([stat])

  def downloads_by_country(stats) when is_list(stats) do
    stats
    |> Enum.map(&(Map.get(&1.demographics, "countries")))
    |> downloads_list_merged_and_sorted
  end
  def downloads_by_country(stat), do: downloads_by_country([stat])

  def downloads_by_os(stats) when is_list(stats) do
    stats
    |> Enum.map(&(Map.get(&1.demographics, "agents")))
    |> Enum.map(fn(agents) ->
      agents
      |> browsers_agents_only
      |> group_agents_by(fn(agent) ->
        case UserAgentParser.detect_os(agent) do
          %UA.OS{family: family} -> family
          :unknown -> "Unknown"
        end
       end)
    end)
    |> downloads_list_merged_and_sorted
  end
  def downloads_by_os(stat), do: downloads_by_os([stat])

  defp downloads_list_merged_and_sorted(list) do
    list
    |> Enum.reduce(fn(x, acc) -> Map.merge(acc, x, fn(_k, v1, v2) -> v1 + v2 end) end)
    |> Enum.sort(&(elem(&1, 1) > elem(&2, 1)))
  end

  defp browsers_agents_only(agents) do
    agents
    |> Enum.filter(fn({agent, _downloads}) -> String.match?(agent, ~r/^Mozilla\//) end)
  end

  defp group_agents_by(agents, groupingFn) do
    Enum.reduce(agents, %{}, fn({agent, downloads}, acc) ->
      Map.update(acc, groupingFn.(agent), downloads, &(&1 + downloads))
    end)
  end
end
