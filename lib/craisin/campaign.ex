defmodule Craisin.Campaign do
  import Craisin

  def summary(campaign_id) do
    get("campaigns/#{campaign_id}/summary") |> handle
  end
end
