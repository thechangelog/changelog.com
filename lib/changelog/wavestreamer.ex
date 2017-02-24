defmodule Changelog.Wavestreamer do
  defmodule Stats do
    defstruct streaming: false, listeners: 0
  end

  def host do
    "http://knight.wavestreamer.com:1882"
  end

  def live_url do
    host() <> "/Live"
  end

  def stats_url do
    host() <> "/stats?sid=1&json=1"
  end

  def get_stats do
    try do
      response = HTTPoison.get!(stats_url())
      decoded = Poison.decode!(response.body)
      %Stats{streaming: (decoded["streamstatus"] == 1),
             listeners: decoded["currentlisteners"]}
    rescue
      HTTPoison.Error    -> %Stats{}
      Poison.SyntaxError -> %Stats{}
    end
  end
end
