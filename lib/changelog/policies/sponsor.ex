defmodule Changelog.Policies.Sponsor do
  use Changelog.Policies.Default

  def index(_actor), do: true
  def pricing(actor), do: index(actor)
  def story(actor), do: index(actor)
  def styles(actor), do: index(actor)

  def show(actor, sponsor) do
    is_admin(actor) || is_rep(actor, sponsor)
  end

  defp is_rep(actor, sponsor) do
    sponsor
    |> Map.get(:reps, [])
    |> Enum.member?(actor)
  end
end
