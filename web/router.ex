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
    pipe_through :browser

    resources "/channels", ChannelController, only: [:show]
    resources "/people", PersonController, only: [:show]
    resources "/posts", PostController, only: [:show]

    # static pages
    get "/", PageController, :index
    get "/weekly", PageController, :weekly, as: :weekly
    get "/nightly", PageController, :nightly, as: :nightly
    get "/contact", PageController, :contact, as: :contact
    get "/films", PageController, :films, as: :films
    get "/membership", PageController, :membership, as: :membership
    get "/sponsorship", PageController, :sponsorship, as: :sponsorship
    get "/partnership", PageController, :partnership, as: :partnership
    get "/store", PageController, :store, as: :store
    get "/team", PageController, :team, as: :team
    get "/about", PageController, :about, as: :about

    get "/in", AuthController, :new, as: :sign_in
    post "/in", AuthController, :new, as: :sign_in
    get "/in/:token", AuthController, :create, as: :create_sign_in
    get "/out", AuthController, :delete, as: :sign_out

    get "/master", PodcastController, :master, as: :podcast_master
    get "/master/feed", PodcastController, :master_feed, as: :podcast_master_feed

    get "/:slug", PodcastController, :show, as: :podcast
    get "/:slug/feed", PodcastController, :feed, as: :podcast_feed
    get "/:podcast/:slug", PodcastController, :episode, as: :episode
  end
end
