defmodule Changelog.AgentKit do
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
end
