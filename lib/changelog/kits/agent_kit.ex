defmodule Changelog.AgentKit do
  @known_agents [
    "Overcast",
    "PlayerFM",
    "Feedbin",
    "Feed Wrangler",
    "Inoreader",
    "NewsBlur",
    "Bloglovin",
    "NewsGator",
    "TheOldReader",
    "G2Reader",
    "Feedly",
    "BazQux"
  ]

  @client_regexes [
    {"Apple TV", ~r/^AppleCoreMedia\/1\.(.*)Apple TV/},
    {"Castro", ~r/^Castro\s/},
    {"Apple Watch", ~r/^AppleCoreMedia\/1\.(.*)Apple Watch/},
    {"Apple Watch", ~r/(.*)watchOS\//},
    {"Google Play", ~r/(.*)Google-Podcast/}
  ]

  # see https://podnews.net/article/podcast-app-useragents
  def get_podcast_client(ua) when is_binary(ua) do
    ua = URI.decode(ua)

    name =
      case Enum.find(@client_regexes, fn {_, regex} -> String.match?(ua, regex) end) do
        {client, _} -> client
        _else -> ua |> String.split("/") |> List.first()
      end

    case name do
      "AndroidDownloadManager" -> "Android"
      "AppleCoreMedia" -> "Apple Podcasts"
      "Mozilla" -> "Browsers"
      _else -> name
    end
  end

  def get_podcast_client(_), do: "Unknown"

  def get_subscribers(nil), do: {:error, :no_ua_string}

  def get_subscribers(ua) do
    subscribers = extract_subscribers(ua)
    agent = extract_known_agent(ua)
    handle(agent, subscribers)
  end

  defp extract_known_agent(ua) do
    Enum.find(@known_agents, fn x -> String.match?(ua, ~r/#{x}/i) end)
  end

  defp extract_subscribers(ua) do
    case Regex.named_captures(~r/(?<subs>\d+) subscribers/, ua) do
      %{"subs" => count} -> String.to_integer(count)
      _else -> 0
    end
  end

  defp handle(_agent, subscribers) when subscribers < 5, do: {:error, :no_subscribers}
  defp handle(agent, _subscribers) when is_nil(agent), do: {:error, :unknown_agent}
  defp handle(agent, subscribers), do: {:ok, {agent, subscribers}}
end
