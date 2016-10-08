defmodule Changelog.Router do
  use Changelog.Web, :router

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Changelog.Plug.Auth, repo: Changelog.Repo

    if Mix.env == :prod do
      plug BasicAuth, realm: "2016", username: "hacker", password: "heart"
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :put_layout, {Changelog.LayoutView, :admin}
    plug Changelog.Plug.RequireAdmin
  end

  pipeline :public do
    plug Changelog.Plug.LoadPodcasts
  end

  scope "/admin", Changelog.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/", PageController, :index
    get "/search", SearchController, :all
    get "/search/channel", SearchController, :channel
    get "/search/person", SearchController, :person
    get "/search/post", SearchController, :post
    get "/search/sponsor", SearchController, :sponsor

    resources "/channels", ChannelController, except: [:show]
    resources "/people", PersonController, except: [:show]
    resources "/podcasts", PodcastController do
      resources "/episodes", EpisodeController
    end
    resources "/posts", PostController
    resources "/sponsors", SponsorController
  end

  scope "/", Changelog do
    pipe_through [:browser, :public]

    #feeds
    get "/feed", FeedController, :all
    get "/posts/feed", FeedController, :posts
    get "/sitemap.xml", FeedController, :sitemap
    get "/:slug/feed", FeedController, :podcast

    resources "/channels", ChannelController, only: [:show]
    resources "/people", PersonController, only: [:show]
    resources "/posts", PostController, only: [:show]

    get "/slack/gotime", SlackController, :gotime

    # static pages
    get "/", PageController, :home
    get "/about", PageController, :about
    get "/contact", PageController, :contact
    get "/films", PageController, :films
    get "/membership", PageController, :membership
    get "/styleguide", PageController, :styleguide
    get "/subscribe", PageController, :subscribe
    get "/partnership", PageController, :partnership
    get "/sponsorship", PageController, :sponsorship
    get "/store", PageController, :store
    get "/soundcheck", PageController, :soundcheck
    get "/team", PageController, :team
    get "/live", PageController, :live

    get "/nightly", PageController, :nightly
    get "/nightly/confirmation-pending", PageController, :nightly_pending
    get "/nightly/confirmed", PageController, :nightly_confirmed
    get "/nightly/unsubscribed", PageController, :nightly_unsubscribed

    get "/weekly", PageController, :weekly
    get "/weekly/archive", PageController, :weekly_archive
    get "/weekly/confirmation-pending", PageController, :weekly_pending
    get "/weekly/confirmed", PageController, :weekly_confirmed
    get "/weekly/unsubscribed", PageController, :weekly_unsubscribed

    get "/in", AuthController, :new, as: :sign_in
    post "/in", AuthController, :new, as: :sign_in
    get "/in/:token", AuthController, :create, as: :create_sign_in
    get "/out", AuthController, :delete, as: :sign_out

    get "/podcasts", PodcastController, :index, as: :podcast
    get "/:slug", PodcastController, :show, as: :podcast
    get "/:slug/archive", PodcastController, :archive, as: :podcast

    get "/:podcast/:slug", EpisodeController, :show, as: :episode
    get "/:podcast/:slug/preview", EpisodeController, :preview, as: :episode
    get "/:podcast/:slug/play", EpisodeController, :play, as: :episode
  end
end
