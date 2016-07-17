alias Changelog.{Repo, Person, Episode, EpisodeHost, EpisodeGuest, Podcast, Topic, Sponsor}

import Ecto
import Ecto.Changeset
import Ecto.Query, only: [from: 1, from: 2]

defmodule H do
  def get(Episode, id), do: Repo.get(Episode, id) |> Repo.preload(:podcast)
  def get(model, id), do: Repo.get(model, id)

  def update(model, id, attrs \\ %{}) do
    Repo.update Ecto.Changeset.change(Repo.get(model, id), attrs)
  end

  def delete(model, id), do:  Repo.delete get(model, id)
end
