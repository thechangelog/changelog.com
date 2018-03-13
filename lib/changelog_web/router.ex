defmodule ChangelogWeb.Router do
  use ChangelogWeb, :router
  use Plug.ErrorHandler

  alias ChangelogWeb.Plug

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Plug.Turbolinks
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plug.Auth, repo: Changelog.Repo
    plug PlugEtsCache.Plug
  end

  pipeline :feed do
    plug :accepts, ["xml"]
    plug PlugEtsCache.Plug
  end

  pipeline :json_feed do
    plug :accepts, ["json"]
    plug PlugEtsCache.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug PlugEtsCache.Plug
  end

  pipeline :admin do
    plug :put_layout, {ChangelogWeb.LayoutView, :admin}
    plug Plug.RequireAdmin
  end

  pipeline :public do
  end

  scope "/auth", ChangelogWeb do
    pipe_through [:browser, :public]

    for provider <- ~w(github twitter) do
      get "/#{provider}", AuthController, :request, as: "#{provider}_auth"
      get "/#{provider}/callback", AuthController, :callback, as: "#{provider}_auth"
      post "/#{provider}/callback", AuthController, :callback, as: "#{provider}_auth"
    end
  end

  scope "/admin", ChangelogWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/", PageController, :index
    get "/search", SearchController, :all
    get "/search/:type", SearchController, :one

    resources "/benefits", BenefitController, except: [:show]
    resources "/topics", TopicController, except: [:show]

    get "/news", NewsItemController, :index
    resources "/news/items", NewsItemController, except: [:show]
    delete "/news/items/:id/decline", NewsItemController, :decline, as: :news_item
    post "/news/items/:id/move", NewsItemController, :move, as: :news_item
    resources "/news/sources", NewsSourceController, except: [:show]
    get "/news/sponsorships/schedule", NewsSponsorshipController, :schedule
    resources "/news/sponsorships", NewsSponsorshipController
    resources "/news/issues", NewsIssueController, except: [:show]
    post "/news/issues/:id/publish", NewsIssueController, :publish, as: :news_issue
    post "/news/issues/:id/unpublish", NewsIssueController, :unpublish, as: :news_issue

    resources "/people", PersonController, except: [:show]
    resources "/podcasts", PodcastController do
      resources "/episodes", EpisodeController
      post "/episodes/:id/publish", EpisodeController, :publish, as: :episode
      post "/episodes/:id/unpublish", EpisodeController, :unpublish, as: :episode
      post "/episodes/:id/transcript", EpisodeController, :transcript, as: :episode
    end
    resources "/posts", PostController, except: [:show]
    resources "/sponsors", SponsorController
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

  scope "/", ChangelogWeb do
    pipe_through [:feed]

    get "/feed", FeedController, :news
    get "/feed/titles", FeedController, :news_titles
    get "/posts/feed", FeedController, :posts
    get "/sitemap.xml", FeedController, :sitemap
    get "/:slug/feed", FeedController, :podcast
  end

  scope "/", ChangelogWeb do
    pipe_through [:json_feed]

    get "/feed.json", JsonFeedController, :news
  end

  scope "/", ChangelogWeb do
    pipe_through [:browser, :public]

    get "/join", PersonController, :join, as: :person
    post "/join", PersonController, :join, as: :person
    get "/subscribe", PersonController, :subscribe, as: :person
    post "/subscribe", PersonController, :subscribe, as: :person

    resources "/~", HomeController, only: [:show, :update], singleton: true
    get "/~/profile", HomeController, :profile
    get "/~/account", HomeController, :account
    get "/~/nope/:token/:notification", HomeController, :opt_out

    post "/~/slack", HomeController, :slack
    post "/~/subscribe/:id", HomeController, :subscribe
    post "/~/unsubscribe/:id", HomeController, :unsubscribe

    get "/in", AuthController, :new, as: :sign_in
    post "/in", AuthController, :new, as: :sign_in
    get "/in/:token", AuthController, :create, as: :sign_in
    get "/out", AuthController, :delete, as: :sign_out

    get "/", NewsItemController, :index, as: :root
    get "/news/submit", NewsItemController, :new
    resources "/news", NewsItemController, only: [:show, :create], as: :news_item
    get "/news/:id/visit", NewsItemController, :visit, as: :news_item
    post "/news/impress", NewsItemController, :impress, as: :news_item
    resources "/ads", NewsAdController, only: [:show], as: :news_ad
    post "/ad/impress", NewsAdController, :impress, as: :news_ad
    get "/ad/:id/visit", NewsAdController, :visit, as: :news_ad
    get "/news/:id/preview", NewsItemController, :preview, as: :news_item
    get "/news/issues/:id", NewsIssueController, :show, as: :news_issue
    get "/news/issues/:id/preview", NewsIssueController, :preview, as: :news_issue

    resources "/benefits", BenefitController, only: [:index]
    resources "/posts", PostController, only: [:index, :show]
    get "/posts/:id/preview", PostController, :preview, as: :post

    get "/sources", NewsSourceController, :index, as: :news_source
    get "/source/:slug", NewsSourceController, :show, as: :news_source
    get "/topics", TopicController, :index, as: :topic
    get "/topic/:slug", TopicController, :show, as: :topic

    get "/live", LiveController, :index
    get "/live/status", LiveController, :status
    get "/search", SearchController, :search

    # static pages
    get "/about", PageController, :about
    get "/coc", PageController, :coc
    get "/community", PageController, :community
    get "/contact", PageController, :contact
    get "/films", PageController, :films
    get "/films/gophercon-2015", PageController, :films_gophercon_2015
    get "/films/gophercon-2016", PageController, :films_gophercon_2016
    get "/guest", PageController, :guest
    get "/guest/:slug", PageController, :guest
    get "/styleguide", PageController, :styleguide
    get "/sponsor", PageController, :sponsor
    get "/sponsor/pricing", PageController, :sponsor_pricing
    get "/team", PageController, :team
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms

    get "/nightly", PageController, :nightly
    get "/nightly/unsubscribed", PageController, :nightly_unsubscribed

    get "/weekly", PageController, :weekly
    get "/weekly/archive", PageController, :weekly_archive
    get "/weekly/unsubscribed", PageController, :weekly_unsubscribed

    get "/podcasts", PodcastController, :index, as: :podcast
    get "/:slug", PodcastController, :show, as: :podcast

    get "/:podcast/:slug", EpisodeController, :show, as: :episode
    get "/:podcast/:slug/embed", EpisodeController, :embed, as: :episode
    get "/:podcast/:slug/preview", EpisodeController, :preview, as: :episode
    get "/:podcast/:slug/play", EpisodeController, :play, as: :episode
    get "/:podcast/:slug/share", EpisodeController, :share, as: :episode
  end

  defp handle_errors(_conn, %{reason: %Ecto.NoResultsError{}}), do: true
  defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}), do: true
  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    headers = Enum.into(conn.req_headers, %{})
    reason = Map.delete(reason, :assigns)

    Rollbax.report(kind, reason, stacktrace, %{}, %{
      "request" => %{
        "url" => "#{conn.scheme}://#{conn.host}#{conn.request_path}",
        "user_ip" => Map.get(headers, "x-forwarded-for"),
        "method" => conn.method,
        "headers" => headers,
        "params" => conn.params
      }
    })
  end
end
