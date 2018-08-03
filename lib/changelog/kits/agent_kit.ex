defmodule Changelog.AgentKit do
  @known_agents ~w(Overcast PlayerFM)

  def get_subscribers(nil), do: {:error, :no_ua_string}
  def get_subscribers(ua) do
    subscribers = extract_subscribers(ua)
    agent = extract_known_agent(ua)
    handle(agent, subscribers)
  end

  defp extract_known_agent(ua) do
    Enum.find(@known_agents, fn(x) -> String.match?(ua, ~r/#{x}/) end)
  end

  defp extract_subscribers(ua) do
    case Regex.named_captures(~r/(?<subs>\d+) subscribers/, ua) do
      %{"subs" => count} -> String.to_integer(count)
      _else -> 0
    end
  end

  defp handle(_agent, subscribers) when subscribers <= 1, do: {:error, :no_subscribers}
  defp handle(agent, _subscribers) when is_nil(agent), do: {:error, :unknown_agent}
  defp handle(agent, subscribers), do: {:ok, {agent, subscribers}}
end
