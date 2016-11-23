defmodule Changelog.Newsletter do
  defstruct name: nil, list_id: nil, web_id: nil, stats: %{}

  alias ConCache.Item
  alias Craisin.List

  def gotime() do
    %__MODULE__{name: "Go Time",
                list_id: "96f7328735b814e82d384ce1ddaf8420",
                web_id: "B4546FE361E47720"}
  end

  def nightly() do
    %__MODULE__{name: "Nightly",
                list_id: "95a8fbc221a2240ac7469d661bac650a",
                web_id: "82E49C221D20C4F7"}
  end

  def weekly() do
    %__MODULE__{name: "Weekly",
                list_id: "eddd53c07cf9e23029fe8a67fe84731f",
                web_id: "82E49C221D20C4F7"}
  end

  def get_stats(newsletter) do
    stats = ConCache.get_or_store(:app_cache, "newsletter_#{newsletter.list_id}_stats", fn() ->
      %Item{value: List.stats(newsletter.list_id), ttl: :timer.hours(1)}
    end)

    %__MODULE__{newsletter | stats: stats}
  end
end
