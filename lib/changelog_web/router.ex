defmodule ChangelogWeb.Router do
  use ChangelogWeb, :router
  use ChangelogWeb.ObanWeb

  alias ChangelogWeb.Plug

  # should be used before :browser pipeline to avoid auth and cache headers
  pipeline :public do
    plug Plug.Robots
    plug Plug.LoadPodcasts
    plug Plug.Redirects
    plug Plug.VanityDomains
  end

  pipeline :admin do
    plug Plug.AdminLayoutPlug
    plug :protect_from_forgery
  end

  pipeline :browser do
    plug :accepts, ["html", "js"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_secure_browser_headers
    plug Plug.Authenticate, repo: Changelog.Repo
    plug Plug.AllowFraming
    # must come after Plug.Authenticate
    plug Plug.CacheControl
  end

  pipeline :feed do
    plug :accepts, ["xml"]
    plug Plug.Redirects
    plug Plug.CacheControl
  end

  pipeline :json_feed do
    plug :accepts, ["json"]
    plug Plug.CacheControl
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", ChangelogWeb do
    pipe_through [:public, :browser]

    for provider <- ~w(github) do
      get "/#{provider}", AuthController, :request, as: "#{provider}_auth"
      get "/#{provider}/callback", AuthController, :callback, as: "#{provider}_auth"
      post "/#{provider}/callback", AuthController, :callback, as: "#{provider}_auth"
    end
  end

  scope "/admin", ChangelogWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/", PageController, :index
    get "/downloads", PageController, :downloads
    get "/fresh_requests", PageController, :fresh_requests
    get "/purge", PageController, :purge
    get "/search", SearchController, :all
    get "/search/:type", SearchController, :one

    resources "/feeds", FeedController
    get "/feeds/:id/agents", FeedController, :agents
    post "/feeds/:id/refresh", FeedController, :refresh, as: :feed

    resources "/memberships", MembershipController, except: [:create, :delete]
    post "/memberships/refresh", MembershipController, :refresh, as: :membership

    resources "/topics", TopicController, except: [:show]
    resources "/events", EventLogController, only: [:index, :delete]

    get "/news", NewsItemController, :index

    resources "/news/items", NewsItemController, except: [:show] do
      resources "/subscriptions", NewsItemSubscriptionController,
        as: :subscription,
        only: [:index]
    end

    post "/news/items/:id/accept", NewsItemController, :accept, as: :news_item
    delete "/news/items/:id/decline", NewsItemController, :decline, as: :news_item
    post "/news/items/:id/unpublish", NewsItemController, :unpublish, as: :news_item
    post "/news/items/:id/move", NewsItemController, :move, as: :news_item
    resources "/news/comments", NewsItemCommentController, except: [:show, :new, :create]
    resources "/news/sources", NewsSourceController, except: [:show]
    get "/news/sponsorships/schedule", NewsSponsorshipController, :schedule
    resources "/news/sponsorships", NewsSponsorshipController
    resources "/news/issues", NewsIssueController, except: [:show]
    post "/news/issues/:id/publish", NewsIssueController, :publish, as: :news_issue
    post "/news/issues/:id/unpublish", NewsIssueController, :unpublish, as: :news_issue

    resources "/people", PersonController
    get "/people/:id/news", PersonController, :news, as: :person
    get "/people/:id/comments", PersonController, :comments, as: :person
    post "/people/:id/slack", PersonController, :slack, as: :person
    post "/people/:id/zulip", PersonController, :zulip, as: :person
    post "/people/:id/masq", PersonController, :masq, as: :person

    resources "/podcasts", PodcastController do
      resources "/episodes", EpisodeController
      get "/performance", EpisodeController, :performance, as: :performance
      get "/youtube", EpisodeController, :youtube, as: :youtube
      post "/youtube", EpisodeController, :youtube, as: :youtube

      post "/episodes/:id/publish", EpisodeController, :publish, as: :episode
      post "/episodes/:id/unpublish", EpisodeController, :unpublish, as: :episode
      post "/episodes/:id/transcript", EpisodeController, :transcript, as: :episode

      resources "/episode_requests", EpisodeRequestController

      put "/episode_requests/:id/decline", EpisodeRequestController, :decline,
        as: :episode_request

      put "/episode_requests/:id/fail", EpisodeRequestController, :fail, as: :episode_request
      put "/episode_requests/:id/pend", EpisodeRequestController, :pend, as: :episode_request

      resources "/subscriptions", PodcastSubscriptionController, as: :subscription, only: [:index]
    end

    get "/podcasts/:id/agents", PodcastController, :agents

    post "/podcasts/:id/feed", PodcastController, :feed, as: :podcast

    resources "/posts", PostController, except: [:show]
    post "/posts/:id/publish", PostController, :publish, as: :post
    post "/posts/:id/unpublish", PostController, :unpublish, as: :post

    resources "/sponsors", SponsorController
    resources "/mailers", MailerPreviewController, only: [:index, :show]
    get "/mailers/:id/send", MailerPreviewController, :send, as: :mailer_preview
  end

  scope "/api", ChangelogWeb, as: :api do
    pipe_through [:api]

    get "/oembed", ApiController, :oembed
  end

  scope "/github", ChangelogWeb do
    pipe_through [:api]

    post "/event", GithubController, :event
  end

  scope "/slack", ChangelogWeb do
    pipe_through [:api]

    get "/countdown/:slug", SlackController, :countdown
    post "/countdown/:slug", SlackController, :countdown
    post "/event", SlackController, :event
  end

  scope "/stripe", ChangelogWeb do
    pipe_through [:api]

    post "/event", StripeController, :event
  end

  scope "/", ChangelogWeb do
    pipe_through [:feed]

    get "/feed", FeedController, :news
    get "/posts/feed", FeedController, :posts
    get "/sitemap.xml", FeedController, :sitemap
    get "/:slug/feed", FeedController, :podcast
    get "/plusplus/:slug/feed", FeedController, :plusplus
    get "/feeds/:slug", FeedController, :custom
  end

  scope "/", ChangelogWeb do
    pipe_through [:json_feed]

    get "/feed.json", JsonFeedController, :news
  end

  scope "/", ChangelogWeb do
    pipe_through [:public, :browser]

    get "/join", PersonController, :join, as: :person
    post "/join", PersonController, :join, as: :person
    get "/subscribe", PersonController, :subscribe, as: :person
    get "/subscribe/:to", PersonController, :subscribe, as: :person
    post "/subscribe", PersonController, :subscribe, as: :person
    get "/person/:handle", PersonController, :show, as: :person
    get "/person/:handle/news", PersonController, :news, as: :person
    get "/person/:handle/podcasts", PersonController, :podcasts, as: :person

    resources "/~", HomeController, only: [:show, :update], singleton: true
    get "/~/profile", HomeController, :profile
    get "/~/account", HomeController, :account
    get "/~/nope/:token/:type/:id", HomeController, :opt_out
    post "/~/nope/:token/:type/:id", HomeController, :opt_out

    post "/~/slack", HomeController, :slack
    post "/~/zulip", HomeController, :zulip
    post "/~/subscribe", HomeController, :subscribe
    post "/~/unsubscribe", HomeController, :unsubscribe

    resources "/~/feeds", Home.FeedController
    post "/~/feeds/:id/email", Home.FeedController, :email
    post "/~/feeds/:id/refresh", Home.FeedController, :refresh

    get "/in", AuthController, :new, as: :sign_in
    post "/in", AuthController, :new, as: :sign_in
    get "/in/:token", AuthController, :create, as: :sign_in
    post "/in/:token", AuthController, :create, as: :sign_in
    get "/out", AuthController, :delete, as: :sign_out

    get "/", PageController, :index, as: :root

    get "/sponsor/pricing", SponsorController, :pricing
    get "/sponsor/styles", SponsorController, :styles
    get "/sponsor/stories/:slug", SponsorController, :story
    resources "/sponsor", SponsorController, only: [:index, :show]

    resources "/sponsored", NewsAdController, only: [:show], as: :news_sponsored
    post "/sponsored/impress", NewsAdController, :impress, as: :news_sponsored
    post "/sponsored/:id/visit", NewsAdController, :visit, as: :news_ad
    # we use post now 👆 legacy route for extant <a> tags 👇
    get "/sponsored/:id/visit", NewsAdController, :visit, as: :news_sponsored

    get "/news/issues/:id", NewsIssueController, :show, as: :news_issue
    get "/news/issues/:id/preview", NewsIssueController, :preview, as: :news_issue

    resources "/news/comments", NewsItemCommentController, only: [:create, :update]
    post "/news/comments/preview", NewsItemCommentController, :preview, as: :news_item_comment

    resources "/posts", PostController, only: [:index, :show]
    get "/posts/:id/preview", PostController, :preview, as: :post

    get "/sources", NewsSourceController, :index, as: :news_source
    get "/source/:slug", NewsSourceController, :show, as: :news_source
    get "/topics", TopicController, :index, as: :topic
    get "/topic/:slug", TopicController, :show, as: :topic
    get "/topic/:slug/news", TopicController, :news, as: :topic
    get "/topic/:slug/podcasts", TopicController, :podcasts, as: :topic

    get "/live", LiveController, :index
    get "/live/ical", LiveController, :ical
    get "/live/ical/:slug", LiveController, :ical
    get "/live/status", LiveController, :status
    get "/live/:id", LiveController, :show

    get "/search", SearchController, :search

    # static pages
    get "/manifest.json", PageController, :manifest_json
    get "/about", PageController, :about
    get "/coc", PageController, :coc
    get "/community", PageController, :community
    get "/contact", PageController, :contact
    get "/contribute", PageController, :contribute
    get "/films", PageController, :films
    get "/films/gophercon-2015", PageController, :films_gophercon_2015
    get "/films/gophercon-2016", PageController, :films_gophercon_2016
    get "/films/gophercon-2017", PageController, :films_gophercon_2017
    get "/guest", PageController, :guest
    get "/guest/:slug", PageController, :guest
    get "/styleguide", PageController, :styleguide
    get "/ten", PageController, :ten
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms

    get "/++", PageController, :++
    get "/plusplus", PageController, :plusplus

    get "/nightly", PageController, :nightly
    get "/nightly/unsubscribed", PageController, :nightly_unsubscribed

    get "/request", EpisodeRequestController, :new, as: :episode_request
    get "/request/:slug", EpisodeRequestController, :new, as: :episode_request
    post "/request", EpisodeRequestController, :create, as: :episode_request

    get "/beats", AlbumController, :index, as: :album
    get "/beats/:slug", AlbumController, :show, as: :album

    get "/podcasts", PodcastController, :index, as: :podcast

    for subpage <- ~w(popular recommended archive)a do
      get "/:slug/#{subpage}", PodcastController, subpage, as: :podcast
    end

    # must be after podcast subpages and before episode pages
    get "/news/submit", NewsItemController, :new
    resources "/news", NewsItemController, only: [:show, :create], as: :news_item

    get "/news/:id/preview", NewsItemController, :preview, as: :news_item
    post "/news/:id/visit", NewsItemController, :visit, as: :news_item
    # we use post now 👆 legacy route for extant <a> tags 👇
    get "/news/:id/visit", NewsItemController, :visit, as: :news_item
    get "/news/:id/subscribe", NewsItemController, :subscribe, as: :news_item
    get "/news/:id/unsubscribe", NewsItemController, :unsubscribe, as: :news_item
    post "/news/impress", NewsItemController, :impress, as: :news_item

    get "/:podcast/:slug", EpisodeController, :show, as: :episode
    post "/:podcast/:slug/subscribe", EpisodeController, :subscribe, as: :episode
    post "/:podcast/:slug/unsubscribe", EpisodeController, :unsubscribe, as: :episode

    for subpage <-
          ~w(embed preview play share img discuss transcript live time chapters psc email yt)a do
      get "/:podcast/:slug/#{subpage}", EpisodeController, subpage, as: :episode
    end

    get "/:slug", PodcastController, :show, as: :podcast
  end
end
