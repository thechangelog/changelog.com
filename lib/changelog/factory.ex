defmodule Changelog.Factory do
  use ExMachina.Ecto, repo: Changelog.Repo

  def factory(:person) do
    %Changelog.Person{
      name: sequence(:name, &"Joe Blow #{&1}"),
      email: sequence(:email, &"joe-#{&1}@email.com"),
      handle: sequence(:handle, &"joeblow-#{&1}")
    }
  end

  def factory(:podcast) do
    %Changelog.Podcast{
      name: sequence(:name, &"Show #{&1}"),
      slug: sequence(:slug, &"show-#{&1}")
    }
  end
end
