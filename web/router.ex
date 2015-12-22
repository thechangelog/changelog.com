defmodule Changelog.Router do
  use Changelog.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :put_layout, {Changelog.LayoutView, :admin}
  end

  scope "/", Changelog do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/admin", Changelog.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/", PageController, :index

    resources "/people", PersonController
  end
end
