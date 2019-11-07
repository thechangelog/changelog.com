defmodule ChangelogWeb.Router do
  use ChangelogWeb, :router
  use Plug.ErrorHandler

  alias ChangelogWeb.Plug

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :browser do
    plug :accepts, ["html", "js"]
    plug :fetch_session
    plug Plug.Turbolinks
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug Plug.AllowFraming
    plug Plug.Authenticate, repo: Changelog.Repo
  end

  pipeline :feed do
    plug :accepts, ["xml"]
  end

  pipeline :json_feed do
    plug :accepts, ["json"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :put_layout, {ChangelogWeb.LayoutView, :admin}
  end

  pipeline :public do
    plug Plug.LoadPodcasts
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
    get "/purge", PageController, :purge
    get "/search", SearchController, :all
    get "/search/:type", SearchController, :one

    resources "/benefits", BenefitController, except: [:show]
    resources "/topics", TopicController, except: [:show]

    get "/news", NewsItemController, :index
    resources "/news/items", NewsItemController, except: [:show] do
      resources "/subscriptions", NewsItemSubscriptionController, as: :subscription, only: [:index]
    end
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
    post "/people/:id/slack", PersonController, :slack, as: :person

    resources "/podcasts", PodcastController do
      resources "/episodes", EpisodeController
      post "/episodes/:id/publish", EpisodeController, :publish, as: :episode
      post "/episodes/:id/unpublish", EpisodeController, :unpublish, as: :episode
      post "/episodes/:id/transcript", EpisodeController, :transcript, as: :episode
      resources "/episode_requests", EpisodeRequestController
      delete "/episode_requests/:id/decline", EpisodeRequestController, :decline, as: :episode_request
      resources "/subscriptions", PodcastSubscriptionController, as: :subscription, only: [:index]
    end

    resources "/posts", PostController, except: [:show]
    post "/posts/:id/publish", PostController, :publish, as: :post
    post "/posts/:id/unpublish", PostController, :unpublish, as: :post

    resources "/sponsors", SponsorController
    resources "/mailers", MailerPreviewController, only: [:index, :show]
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
    get "/subscribe/:to", PersonController, :subscribe, as: :person
    post "/subscribe", PersonController, :subscribe, as: :person

    resources "/~", HomeController, only: [:show, :update], singleton: true
    get "/~/profile", HomeController, :profile
    get "/~/account", HomeController, :account
    get "/~/nope/:token/:type/:id", HomeController, :opt_out

    post "/~/slack", HomeController, :slack
    post "/~/subscribe", HomeController, :subscribe
    post "/~/unsubscribe", HomeController, :unsubscribe

    get "/in", AuthController, :new, as: :sign_in
    post "/in", AuthController, :new, as: :sign_in
    get "/in/:token", AuthController, :create, as: :sign_in
    get "/out", AuthController, :delete, as: :sign_out

    get "/", NewsItemController, :index, as: :root
    get "/news/submit", NewsItemController, :new
    get "/news/fresh", NewsItemController, :fresh
    get "/news/top", NewsItemController, :top
    get "/news/top/week", NewsItemController, :top_week
    get "/news/top/month", NewsItemController, :top_month
    get "/news/top/all", NewsItemController, :top_all
    resources "/news", NewsItemController, only: [:show, :create], as: :news_item
    get "/news/:id/preview", NewsItemController, :preview, as: :news_item
    get "/news/:id/visit", NewsItemController, :visit, as: :news_item
    get "/news/:id/subscribe", NewsItemController, :subscribe, as: :news_item
    get "/news/:id/unsubscribe", NewsItemController, :unsubscribe, as: :news_item
    post "/news/impress", NewsItemController, :impress, as: :news_item
    resources "/ads", NewsAdController, only: [:show], as: :news_ad
    post "/ad/impress", NewsAdController, :impress, as: :news_ad
    get "/ad/:id/visit", NewsAdController, :visit, as: :news_ad

    resources "/sponsored", NewsAdController, only: [:show], as: :news_sponsored
    post "/sponsored/impress", NewsAdController, :impress, as: :news_sponsored
    get "/sponsored/:id/visit", NewsAdController, :visit, as: :news_sponsored
    get "/news/issues/:id", NewsIssueController, :show, as: :news_issue
    get "/news/issues/:id/preview", NewsIssueController, :preview, as: :news_issue
    resources "/news/comments", NewsItemCommentController, only: [:create]
    post "/news/comments/preview", NewsItemCommentController, :preview, as: :news_item_comment

    resources "/benefits", BenefitController, only: [:index]
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
    get "/sponsor", PageController, :sponsor
    get "/sponsor/pricing", PageController, :sponsor_pricing
    get "/sponsor/styles", PageController, :sponsor_styles
    get "/sponsor/details", PageController, :sponsor_details
    get "/sponsor/stories/:slug", PageController, :sponsor_story
    get "/team", PageController, :team
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms

    get "/nightly", PageController, :nightly
    get "/nightly/unsubscribed", PageController, :nightly_unsubscribed

    get "/weekly", PageController, :weekly
    get "/weekly/archive", PageController, :weekly_archive
    get "/weekly/unsubscribed", PageController, :weekly_unsubscribed

    get "/request", EpisodeRequestController, :new, as: :episode_request
    get "/request/:slug", EpisodeRequestController, :new, as: :episode_request
    post "/request", EpisodeRequestController, :create, as: :episode_request

    get "/podcasts", PodcastController, :index, as: :podcast
    get "/:slug", PodcastController, :show, as: :podcast
    get "/:slug/popular", PodcastController, :popular, as: :podcast
    get "/:slug/recommended", PodcastController, :recommended, as: :podcast
    get "/:slug/upcoming", PodcastController, :upcoming, as: :podcast

    get "/:podcast/:slug", EpisodeController, :show, as: :episode
    get "/:podcast/:slug/embed", EpisodeController, :embed, as: :episode
    get "/:podcast/:slug/preview", EpisodeController, :preview, as: :episode
    get "/:podcast/:slug/play", EpisodeController, :play, as: :episode
    get "/:podcast/:slug/share", EpisodeController, :share, as: :episode
    get "/:podcast/:slug/discuss", EpisodeController, :discuss, as: :episode
  end

  defp handle_errors(_conn, %{reason: %Ecto.NoResultsError{}}), do: true
  defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}), do: true
  defp handle_errors(_conn, %{reason: %Phoenix.NotAcceptableError{}}), do: true
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
