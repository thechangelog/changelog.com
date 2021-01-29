defmodule Changelog.PromEx.VanityRedirects do
  use PromEx.Plugin

  @impl true
  def event_metrics(_opts) do
    Event.build(
      :changelog_vanity_redirects,
      [
        counter([:changelog, :vanity_redirects],
          event_name: [:changelog, :vanity_redirects],
          description: "Changelog Vanity Redirects",
          tags: [:podcast]
        )
      ]
    )
  end
end
