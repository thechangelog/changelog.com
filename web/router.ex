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
    plug Changelog.Plug.Turbolinks
  end

  scope "/auth", Changelog do
    pipe_through [:browser, :public]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
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

  scope "/api", Changelog, as: :api do
    pipe_through [:api]

    get "/oembed", ApiController, :oembed
  end

  scope "/slack", Changelog do
    pipe_through [:api]

    get "/gotime", SlackController, :gotime
    get "/countdown/:slug", SlackController, :countdown
  end

  scope "/", Changelog do
    pipe_through [:browser, :public]

    #feeds
    get "/feed", FeedController, :all
    get "/posts/feed", FeedController, :posts
    get "/sitemap.xml", FeedController, :sitemap
    get "/:slug/feed", FeedController, :podcast

    # people and auth
    resources "/people", PersonController, only: [:new, :create]
    resources "/~", HomeController, only: [:show, :edit, :update], singleton: true
    post "/~/slack", HomeController, :slack
    post "/~/subscribe/:id", HomeController, :subscribe
    post "/~/unsubscribe/:id", HomeController, :unsubscribe

    get "/community", PageController, :community
    get "/join", PageController, :join
    get "/in", AuthController, :new, as: :sign_in
    post "/in", AuthController, :new, as: :sign_in
    get "/in/:token", AuthController, :create, as: :sign_in
    get "/out", AuthController, :delete, as: :sign_out

    resources "/posts", PostController, only: [:index, :show]
    get "/posts/:id/preview", PostController, :preview, as: :post

    get "/live", LiveController, :index
    get "/live/status", LiveController, :status
    get "/search", SearchController, :search

    # static pages
    get "/", PageController, :home
    get "/about", PageController, :about
    get "/contact", PageController, :contact
    get "/films", PageController, :films
    get "/films/gophercon-2015", PageController, :films_gophercon_2015
    get "/films/gophercon-2016", PageController, :films_gophercon_2016
    get "/guest/:slug", PageController, :guest
    get "/guest", PageController, :guest
    get "/benefits", PageController, :benefits
    get "/styleguide", PageController, :styleguide
    get "/subscribe", PageController, :subscribe
    get "/partnership", PageController, :partnership
    get "/sponsor", PageController, :sponsor
    get "/store", PageController, :store
    get "/team", PageController, :team
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms

    get "/nightly", PageController, :nightly
    get "/nightly/confirmed", PageController, :nightly_confirmed
    get "/nightly/unsubscribed", PageController, :nightly_unsubscribed

    get "/weekly", PageController, :weekly
    get "/weekly/archive", PageController, :weekly_archive
    get "/weekly/confirmed", PageController, :weekly_confirmed
    get "/weekly/unsubscribed", PageController, :weekly_unsubscribed

    get "/gotime/confirmed", PageController, :gotime_confirmed
    get "/rfc/confirmed", PageController, :rfc_confirmed

    get "/confirmation-pending", PageController, :confirmation_pending

    get "/podcasts", PodcastController, :index, as: :podcast
    get "/:slug", PodcastController, :show, as: :podcast
    get "/:slug/archive", PodcastController, :archive, as: :podcast

    get "/:podcast/:slug", EpisodeController, :show, as: :episode
    get "/:podcast/:slug/embed", EpisodeController, :embed, as: :episode
    get "/:podcast/:slug/preview", EpisodeController, :preview, as: :episode
    get "/:podcast/:slug/play", EpisodeController, :play, as: :episode
    get "/:podcast/:slug/share", EpisodeController, :share, as: :episode
  end
end
