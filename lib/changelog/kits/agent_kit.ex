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

  @bots Application.app_dir(:changelog, "/priv/repo/agents/bots.json") |> File.read!() |> Jason.decode!
  @apps Application.app_dir(:changelog, "/priv/repo/agents/apps.json") |> File.read!() |> Jason.decode!
  @libs Application.app_dir(:changelog, "/priv/repo/agents/libraries.json") |> File.read!() |> Jason.decode!
  @browsers Application.app_dir(:changelog, "/priv/repo/agents/browsers.json") |> File.read!() |> Jason.decode!

  def identify(ua) when is_binary(ua) do
    cond do
      agent = find_in(@bots, ua) -> %{name: agent["name"], type: "bot"}
      agent = find_in(@apps, ua) -> %{name: agent["name"], type: "app"}
      agent = find_in(@libs, ua) -> %{name: agent["name"], type: "library"}
      agent = find_in(@browsers, ua) -> %{name: agent["name"], type: "browser"}
      :else -> %{name: "Unknown", type: "unknown"}
    end
  end

  defp find_in(list, ua) do
    Enum.find(list["entries"], fn entry ->
      String.match?(ua, ~r/#{entry["pattern"]}/)
    end)
  end

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
