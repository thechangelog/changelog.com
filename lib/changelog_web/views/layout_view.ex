defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{Meta, PersonView, PodcastView}

  def preloaded_fonts, do: ~w(roboto-mono-400 SanaSansAlt-Regular
    SanaSansAlt-Medium SanaSansAlt-Black SanaSansAlt-Bold SanaSansAlt-Italic)

  def preloaded_news_fonts,
    do: ~w(roboto-mono-400 SanaSansAlt-Regular SanaSansAlt-Black SanaSansAlt-Italic)
end
