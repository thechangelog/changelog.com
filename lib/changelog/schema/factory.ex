defmodule Changelog.Factory do
  use ExMachina.Ecto, repo: Changelog.Repo

  def feed_factory do
    %Changelog.Feed{
      name: "My Private Feed",
      slug: sequence(:slug, &"feed#{&1}"),
      owner: build(:person)
    }
  end

  def feed_stat_factory do
    %Changelog.FeedStat{
      date: Timex.today(),
      agents: %{}
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
      audio_bytes: 42,
      audio_chapters: [
        build(:episode_chapter, title: "Intro", starts_at: 0, ends_at: 30),
        build(:episode_chapter, title: "Oh & my", starts_at: 31, ends_at: 45)
      ],
      podcast: build(:podcast)
    }
  end

  def episode_chapter_factory do
    %Changelog.EpisodeChapter{
      title: sequence(:title, &"Chapter #{&1}"),
      starts_at: 0.0
    }
  end

  def episode_stat_factory do
    %Changelog.EpisodeStat{
      date: Timex.today(),
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

  def episode_request_factory do
    %Changelog.EpisodeRequest{
      pitch: "You gotta do this!",
      podcast: build(:podcast),
      submitter: build(:person)
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

  def episode_topic_factory do
    %Changelog.EpisodeTopic{
      episode: build(:episode),
      topic: build(:topic)
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

  def news_ad_factory do
    %Changelog.NewsAd{
      url: "https://apple.com",
      headline: "Apple Inc Is Cool I Guess?",
      sponsorship: build(:news_sponsorship)
    }
  end

  def news_issue_factory do
    %Changelog.NewsIssue{
      slug: sequence(:slug, &"#{&1}"),
      note: "Hope you like it"
    }
  end

  def news_issue_ad_factory do
    %Changelog.NewsIssueAd{
      issue: build(:news_issue),
      ad: build(:news_ad)
    }
  end

  def published_news_issue_factory do
    %Changelog.NewsIssue{news_issue_factory() | published: true, published_at: hours_ago(1)}
  end

  def news_item_factory do
    %Changelog.NewsItem{
      type: :link,
      status: :draft,
      headline: sequence(:headline, &"Read all about it #{&1}!"),
      url: "https://changelog.com/posts/read-all-about-it",
      logger: build(:person)
    }
  end

  def published_news_item_factory do
    %Changelog.NewsItem{news_item_factory() | status: :published, published_at: hours_ago(1)}
  end

  def episode_news_item(episode) do
    object_id = Changelog.Episode.object_id(episode)

    %{
      published_news_item_factory()
      | type: :audio,
        headline: episode.title,
        url: "https://changelog.com/episodes/#{episode.slug}",
        object_id: object_id
    }
  end

  def episode_news_item_feed_only(episode) do
    object_id = Changelog.Episode.object_id(episode)

    %{
      published_news_item_factory()
      | type: :audio,
        feed_only: true,
        headline: episode.title,
        url: "https://changelog.com/episodes/#{episode.slug}",
        object_id: object_id
    }
  end

  def episode_news_item_with_story(episode, story) do
    %{episode_news_item(episode) | story: story}
  end

  def post_news_item(post) do
    object_id = Changelog.Post.object_id(post)

    %{
      published_news_item_factory()
      | type: :post,
        headline: post.title,
        url: "https://changelog.com/posts/#{post.slug}",
        object_id: object_id
    }
  end

  def post_news_item_with_story(post, story) do
    %{post_news_item(post) | story: story}
  end

  def news_item_comment_factory do
    %Changelog.NewsItemComment{
      approved: true,
      news_item: build(:news_item),
      author: build(:person),
      content: "Oh noes you di'int!"
    }
  end

  def news_item_topic_factory do
    %Changelog.NewsItemTopic{
      news_item: build(:news_item),
      topic: build(:topic)
    }
  end

  def news_queue_factory do
    %Changelog.NewsQueue{
      position: sequence(:position, & &1),
      item: build(:news_item)
    }
  end

  def news_source_factory do
    %Changelog.NewsSource{
      name: sequence(:name, &"News Source #{&1}"),
      slug: sequence(:name, &"news-source-#{&1}"),
      website: "https://newssource.com"
    }
  end

  def news_sponsorship_factory do
    %Changelog.NewsSponsorship{
      name: "Test Sponsorship",
      sponsor: build(:sponsor),
      weeks: []
    }
  end

  def active_news_sponsorship_factory do
    week = Timex.beginning_of_week(Timex.today())
    %Changelog.NewsSponsorship{news_sponsorship_factory() | weeks: [week]}
  end

  def person_factory do
    %Changelog.Person{
      name: sequence(:name, &"Joe Blow #{&1}"),
      email: sequence(:email, &"joe-#{&1}@email.com"),
      handle: sequence(:handle, &"joeblow-#{&1}"),
      settings: %Changelog.Person.Settings{},
      approved: true,
      admin: false
    }
  end

  def member_factory do
    %Changelog.Person{
      person_factory()
      | active_membership: build(:membership)
    }
  end

  def membership_factory do
    %Changelog.Membership{
      status: "active",
      started_at: hours_ago(1),
      subscription_id: sequence(:subscription_id, &"member-#{&1}")
    }
  end

  def podcast_factory do
    %Changelog.Podcast{
      name: sequence(:name, &"Show #{&1}"),
      slug: sequence(:slug, &"show-#{&1}"),
      status: :publishing
    }
  end

  def live_podcast_factory do
    %Changelog.Podcast{
      podcast_factory()
      | riverside_url: "https://riverside.fm/studio/livepod?t=123"
    }
  end

  def post_factory do
    %Changelog.Post{
      title: sequence(:name, &"Post #{&1}"),
      slug: sequence(:slug, &"post-#{&1}"),
      author: build(:person)
    }
  end

  def post_topic_factory do
    %Changelog.PostTopic{
      post: build(:post),
      topic: build(:topic)
    }
  end

  def publishable_post_factory do
    %Changelog.Post{post_factory() | tldr: "tldr", body: "ohai", published_at: hours_ago(1)}
  end

  def published_post_factory do
    %Changelog.Post{publishable_post_factory() | published: true, published_at: hours_ago(1)}
  end

  def scheduled_post_factory do
    %Changelog.Post{publishable_post_factory() | published: true, published_at: hours_from_now(1)}
  end

  def sponsor_factory do
    %Changelog.Sponsor{
      name: sequence(:name, &"Sponsor #{&1}")
    }
  end

  def subscription_on_episode_factory do
    %Changelog.Subscription{
      person: build(:person),
      episode: build(:episode),
      context: "you got it from a factory"
    }
  end

  def unsubscribed_subscription_on_episode_factory do
    %Changelog.Subscription{subscription_on_episode_factory() | unsubscribed_at: hours_ago(24)}
  end

  def subscription_on_item_factory do
    %Changelog.Subscription{
      person: build(:person),
      item: build(:news_item),
      context: "you got it from a factory"
    }
  end

  def unsubscribed_subscription_on_item_factory do
    %Changelog.Subscription{subscription_on_item_factory() | unsubscribed_at: hours_ago(24)}
  end

  def subscription_on_podcast_factory do
    %Changelog.Subscription{
      person: build(:person),
      podcast: build(:podcast),
      context: "you got it from a factory"
    }
  end

  def unsubscribed_subscription_on_podcast_factory do
    %Changelog.Subscription{subscription_on_podcast_factory() | unsubscribed_at: hours_ago(24)}
  end

  defp hours_ago(count) do
    count
    |> ChangelogWeb.TimeView.hours_ago()
    |> DateTime.truncate(:second)
  end

  defp hours_from_now(count) do
    count
    |> ChangelogWeb.TimeView.hours_from_now()
    |> DateTime.truncate(:second)
  end
end
