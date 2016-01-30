defmodule Changelog.Factory do
  use ExMachina.Ecto, repo: Changelog.Repo

  def factory(:episode) do
    %Changelog.Episode{
      title: sequence(:title, &"Best Show Evar! #{&1}"),
      slug: sequence(:slug, &"best-show-evar-#{&1}"),
      podcast: build(:podcast)
    }
  end

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

  def factory(:topic) do
    %Changelog.Topic{
      name: sequence(:name, &"Topic #{&1}"),
      slug: sequence(:slug, &"topic-#{&1}")
    }
  end
end
