defmodule Changelog.EpisodeStat do
  use Changelog.Schema, default_sort: :date

  alias Changelog.{AgentKit, Episode, Podcast}

  schema "episode_stats" do
    field :date, :date
    field :episode_bytes, :integer
    field :total_bytes, :integer
    field :downloads, :float
    field :uniques, :integer
    field :demographics, :map

    belongs_to :episode, Episode
    belongs_to :podcast, Podcast

    timestamps()
  end

  def between(query \\ __MODULE__, start_date, end_date),
    do: from(q in query, where: q.date < ^end_date, where: q.date >= ^start_date)

  def on_date(query \\ __MODULE__, date), do: from(q in query, where: q.date == ^date)
  def sum_reach(query \\ __MODULE__), do: from(q in query, select: sum(q.uniques))

  def on_full_episodes(query \\ __MODULE__) do
    from(q in query,
      left_join: e in Episode,
      on: [id: q.episode_id],
      where: e.type == ^:full
    )
  end

  def sum_episode_reach(query \\ __MODULE__) do
    from(q in query,
      group_by: q.episode_id,
      select: %{episode_id: q.episode_id, reach: fragment("sum(?) as reach", q.uniques)},
      order_by: [desc: fragment("reach")]
    )
  end

  def sum_downloads(query \\ __MODULE__), do: from(q in query, select: sum(q.downloads))

  def oldest_date do
    Repo.one(from s in __MODULE__, select: [min(s.date)], limit: 1)
    |> List.first()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      ~w(date episode_id podcast_id episode_bytes total_bytes downloads uniques demographics)a
    )
    |> validate_required([:date, :episode_id, :podcast_id])
    |> foreign_key_constraint(:episode_id)
    |> foreign_key_constraint(:podcast_id)
  end

  def downloads_by_browser(stats) when is_list(stats) do
    stats
    |> Enum.map(&Map.get(&1.demographics, "agents"))
    |> Enum.map(fn agents ->
      agents
      |> browsers_agents_only()
      |> group_agents_by(fn agent ->
        case UserAgentParser.detect_browser(agent) do
          %UA.Browser{family: family} -> family
          :unknown -> "Unknown"
        end
      end)
    end)
    |> downloads_list_merged_and_sorted()
  end

  def downloads_by_browser(stat), do: downloads_by_browser([stat])

  def downloads_by_client(stats) when is_list(stats) do
    stats
    |> Enum.map(&Map.get(&1.demographics, "agents"))
    |> Enum.map(fn agents ->
      Enum.reduce(agents, %{}, fn {agent, downloads}, acc ->
        key = AgentKit.get_podcast_client(agent)
        Map.update(acc, key, downloads, &(&1 + downloads))
      end)
    end)
    |> downloads_list_merged_and_sorted()
  end

  def downloads_by_client(stat), do: downloads_by_client([stat])

  def downloads_by_country(stats) when is_list(stats) do
    stats
    |> Enum.map(&Map.get(&1.demographics, "countries"))
    |> downloads_list_merged_and_sorted()
  end

  def downloads_by_country(stat), do: downloads_by_country([stat])

  def downloads_by_os(stats) when is_list(stats) do
    stats
    |> Enum.map(&Map.get(&1.demographics, "agents"))
    |> Enum.map(fn agents ->
      agents
      |> browsers_agents_only
      |> group_agents_by(fn agent ->
        case UserAgentParser.detect_os(agent) do
          %UA.OS{family: family} -> family
          :unknown -> "Unknown"
        end
      end)
    end)
    |> downloads_list_merged_and_sorted()
  end

  def downloads_by_os(stat), do: downloads_by_os([stat])

  def date_range_reach(label) do
    {older_date, newer_date} = reach_dates(label)

    __MODULE__
    |> between(older_date, newer_date)
    |> on_full_episodes()
    |> sum_reach()
    |> Repo.one()
    |> Kernel.||(0)
  end

  def date_range_reach(podcast = %Podcast{}, label) do
    {older_date, newer_date} = reach_dates(label)

    podcast
    |> assoc(:episode_stats)
    |> between(older_date, newer_date)
    |> on_full_episodes()
    |> sum_reach()
    |> Repo.one()
    |> Kernel.||(0)
  end

  def date_range_episode_reach({older_date, newer_date}, minimum) do
    __MODULE__
    |> between(older_date, newer_date)
    |> on_full_episodes()
    |> sum_episode_reach()
    |> Repo.all()
    |> Enum.reject(fn %{reach: reach} -> reach < minimum end)
  end

  def date_range_episode_reach(podcast = %Podcast{}, {older_date, newer_date}, minimum) do
    podcast
    |> assoc(:episode_stats)
    |> between(older_date, newer_date)
    |> on_full_episodes()
    |> sum_episode_reach()
    |> Repo.all()
    |> Enum.reject(fn %{reach: reach} -> reach < minimum end)
  end

  # returns a tuple to be used in 'between' queries and the like
  # tuple contents is {older_date, newer_date}
  def reach_dates(label) do
    now = Timex.today() |> Timex.shift(days: -1)

    case label do
      :now_7 ->
        {Timex.shift(now, days: -7), now}

      :now_30 ->
        {Timex.shift(now, days: -30), now}

      :now_90 ->
        {Timex.shift(now, days: -90), now}

      :now_year ->
        {Timex.shift(now, years: -1), now}

      :prev_7 ->
        prev = Timex.shift(now, days: -7)
        {Timex.shift(prev, days: -7), prev}

      :prev_30 ->
        prev = Timex.shift(now, days: -30)
        {Timex.shift(prev, days: -30), prev}

      :prev_90 ->
        prev = Timex.shift(now, days: -90)
        {Timex.shift(prev, days: -90), prev}

      :prev_year ->
        prev = Timex.shift(now, years: -1)
        {Timex.shift(prev, years: -1), prev}

      :then_7 ->
        then = Timex.shift(now, years: -1)
        {Timex.shift(then, days: -7), then}

      :then_30 ->
        then = Timex.shift(now, years: -1)
        {Timex.shift(then, days: -30), then}

      :then_90 ->
        then = Timex.shift(now, years: -1)
        {Timex.shift(then, days: -90), then}
    end
  end

  defp downloads_list_merged_and_sorted(list) do
    list
    |> Enum.reduce(fn x, acc -> Map.merge(acc, x, fn _k, v1, v2 -> v1 + v2 end) end)
    |> Enum.map(fn {k, v} -> {k, Float.round(v, 2)} end)
    # sort by highest value, then alpha by name
    |> Enum.sort(fn {ak, av}, {bk, bv} -> if av == bv, do: ak < bk, else: av > bv end)
  end

  defp browsers_agents_only(agents) do
    agents |> Enum.filter(fn {agent, _downloads} -> String.match?(agent, ~r/^Mozilla\//) end)
  end

  defp group_agents_by(agents, groupingFn) do
    Enum.reduce(agents, %{}, fn {agent, downloads}, acc ->
      Map.update(acc, groupingFn.(agent), downloads, &(&1 + downloads))
    end)
  end
end
