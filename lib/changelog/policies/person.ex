defmodule Changelog.Policies.Person do
  use Changelog.Policies.Default

  alias Changelog.Person

  def profile(actor, person) do
    update(actor, person) &&
      Person.episode_count(person) > 0
  end

  def update(%{id: actor_id}, %{id: person_id}), do: actor_id == person_id
  def update(_actor, _person), do: false
end
