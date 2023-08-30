defmodule Changelog.PodPing do
  alias Changelog.HTTP

  def overcast(url) do
    HTTP.post("https://overcast.fm/ping", {:form, [{"urlprefix", url}]})
  end
end
