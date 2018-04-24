defmodule Craisin.Campaign do
  import Craisin

  def summary(campaign_id), do: "/campaigns/#{campaign_id}/summary" |> get |> handle
end
