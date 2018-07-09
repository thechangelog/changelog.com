defmodule Changelog.AgentKit do
  def is_overcast(agent), do: String.match?((agent || ""), ~r/Overcast/i)

  def get_overcast_subs(agent) do
    if is_overcast(agent) do
      subs =
        ~r/(\d+) subscribers/
        |> Regex.run(agent)
        |> List.last
        |> String.to_integer

      if subs > 1 do
        {:ok, subs}
      else
        {:error, "Not enough subscribers"}
      end
    else
      {:error, "Agent is not Overcast"}
    end
  end
end
