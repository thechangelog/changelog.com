defmodule Changelog.Factory do
  use ExMachina.Ecto, repo: Changelog.Repo

  import ChangelogWeb.TimeView, only: [hours_from_now: 1, hours_ago: 1]

  def benefit_factory do
    %Changelog.Benefit{
      offer: "Free stuff!",
      sponsor: build(:sponsor),
      link_url: "https://benefits.com"
    }
  end

  def topic_factory do
    %Changelog.Topic{
      name: sequence(:name, &"Topic #{&1}"),
      slug: sequence(:slug, &"topic-#{&1}")
    }
  end

  def episode_factory do
    %Changelog.Episode{
      title: sequence(:title, &"Best Show Evar! #{&1}"),
      slug: sequence(:slug, &"best-show-evar-#{&1}"),
      podcast: build(:podcast)
    }
  end

  def episode_stat_factory do
    %Changelog.EpisodeStat{
      date: Timex.today,
      episode: build(:episode),
      podcast: build(:podcast),
      downloads: 0.0,
      uniques: 0,
      demographics: %{"agents" => %{}, "countries" => %{}}
    }
  end

  def episode_guest_factory do
    %Changelog.EpisodeGuest{
      episode: build(:episode),
      person: build(:person),
      position: 1
    }
  end

  def episode_host_factory do
    %Changelog.EpisodeHost{
      episode: build(:episode),
      person: build(:person),
      position: 1
    }
  end

  def episode_sponsor_factory do
    %Changelog.EpisodeSponsor{
      episode: build(:episode),
      sponsor: build(:sponsor),
      title: "Google",
      link_url: "https://google.com",
      description: "Don't be evil",
      position: 1
    }
  end

  def live_episode_factory do
    %Changelog.Episode{episode_factory() | recorded_live: true}
  end

  def publishable_episode_factory do
    %Changelog.Episode{episode_factory() | summary: "An episode", published_at: hours_ago(1)}
  end

  def published_episode_factory do
    %Changelog.Episode{episode_factory() | published: true, published_at: hours_ago(1)}
  end

  def scheduled_episode_factory do
    %Changelog.Episode{episode_factory() | published: true, published_at: hours_from_now(1)}
  end

  def news_issue_factory do
    %Changelog.NewsIssue{
      slug: sequence(:slug, &"#{&1}"),
      note: "Hope you like it"
    }
  end

  def published_news_issue_factory do
    %Changelog.NewsIssue{news_issue_factory() | published: true, published_at: hours_ago(1)}
  end

  def news_item_factory do
    %Changelog.NewsItem{
      type: :link,
      status: :queued,
      headline: sequence(:headline, &"Read all about it #{&1}!"),
      url: "https://changelog.com/posts/read-all-about-it",
      logger: build(:person)
    }
  end

  def published_news_item_factory do
    %Changelog.NewsItem{news_item_factory() | status: :published, published_at: hours_ago(1)}
  end

  def news_queue_factory do
    %Changelog.NewsQueue{
      position: sequence(:position, &(&1)),
      item: build(:news_item)
    }
  end

  def news_source_factory do
    %Changelog.NewsSource{
      name: "Wired",
      slug: "wired",
      website: "https://wired.com"
    }
  end

  def news_sponsorship_factory do
    %Changelog.NewsSponsorship{
      name: "Test Sponsorship",
      sponsor: build(:sponsor),
      weeks: []
    }
  end

  def person_factory do
    %Changelog.Person{
      name: sequence(:name, &"Joe Blow #{&1}"),
      email: sequence(:email, &"joe-#{&1}@email.com"),
      handle: sequence(:handle, &"joeblow-#{&1}"),
      admin: false
    }
  end

  def podcast_factory do
    %Changelog.Podcast{
      name: sequence(:name, &"Show #{&1}"),
      slug: sequence(:slug, &"show-#{&1}"),
      status: :published
    }
  end

  def post_factory do
    %Changelog.Post{
      title: sequence(:name, &"Post #{&1}"),
      slug: sequence(:slug, &"post-#{&1}"),
      author: build(:person)
    }
  end

  def published_post_factory do
    %Changelog.Post{post_factory() | published: true, published_at: hours_ago(1)}
  end

  def scheduled_post_factory do
    %Changelog.Post{post_factory() | published: true, published_at: hours_from_now(1)}
  end

  def sponsor_factory do
    %Changelog.Sponsor{
      name: sequence(:name, &"Sponsor #{&1}")
    }
  end
end
