defmodule Changelog.Newsletters do

  alias Changelog.Newsletters.Newsletter
  alias ConCache.Item
  alias Craisin.List

  def community() do
    %Newsletter{name: "Community",
                list_id: "08773ce58bee33c04899904bc699a7e8",
                web_id: "C7D35AA52CE2DAF7"}
  end

  def gotime() do
    %Newsletter{name: "Go Time",
                list_id: "96f7328735b814e82d384ce1ddaf8420",
                web_id: "B4546FE361E47720"}
  end

  def jsparty() do
    %Newsletter{name: "JS Party",
                list_id: "20e33901de0aaa012a2cb03a4b5022ae",
                web_id: "7BE6863044968997"}
  end

  def nightly() do
    %Newsletter{name: "Nightly",
                list_id: "95a8fbc221a2240ac7469d661bac650a",
                web_id: "82E49C221D20C4F7"}
  end

  def weekly() do
    %Newsletter{name: "Weekly",
                list_id: "eddd53c07cf9e23029fe8a67fe84731f",
                web_id: "82E49C221D20C4F7"}
  end

  def get_stats(newsletter) do
    stats = ConCache.get_or_store(:app_cache, "newsletter_#{newsletter.list_id}_stats", fn() ->
      %Item{value: List.stats(newsletter.list_id), ttl: :timer.hours(1)}
    end)

    %Newsletter{newsletter | stats: stats}
  end
end
