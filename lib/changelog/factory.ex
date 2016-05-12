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

  def factory(:post) do
    %Changelog.Post{
      title: sequence(:name, &"Post #{&1}"),
      slug: sequence(:slug, &"post-#{&1}"),
      author: build(:person)
    }
  end

  def factory(:sponsor) do
    %Changelog.Sponsor{
      name: sequence(:name, &"Sponsor #{&1}")
    }
  end

  def factory(:channel) do
    %Changelog.Channel{
      name: sequence(:name, &"Channel #{&1}"),
      slug: sequence(:slug, &"channel-#{&1}")
    }
  end
end
