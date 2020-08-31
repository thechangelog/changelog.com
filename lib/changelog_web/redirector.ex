defmodule ChangelogWeb.Redirector do
  use ChangelogWeb, :router

  alias ChangelogWeb.RedirectController, as: R

  sponsors = [
    {"/datadog",
     "https://www.datadoghq.com/lpgs/?utm_source=Advertisement&utm_medium=Advertisement&utm_campaign=ChangelogPodcast-Tshirt"},
    {"/sentry", "https://sentry.io/from/changelog/"},
    {"/codacy",
     "https://codacy.com/product?utm_source=Changelog&utm_medium=cpm&utm_campaign=Changelog-Podcast"}
  ]

  for {path, destination} <- sponsors do
    get path, R, external: destination
  end

  # allow for 'bare' linking of slugs for The Changelog
  # e.g. https://changelog.com/345 -> https://changelog.com/podcast/345
  for i <- 1..1000 do
    get "/#{i}", R, to: "/podcast/#{i}"
  end

  internal = [
    {"/rss", "/feed"},
    {"/podcast/rss", "/podcast/feed"},
    {"/team", "/about"},
    {"/changeloggers", "/about"},
    {"/membership", "/community"},
    {"/store", "/community"},
    {"/sponsorship", "/sponsor"},
    {"/soundcheck", "/guest"},
    {"/submit", "/news/submit"}
  ]

  for {path, destination} <- internal do
    get path, R, to: destination
  end

  # anything that isn't explicitly matched here is sent to our main router
  forward "/", ChangelogWeb.Router
end
