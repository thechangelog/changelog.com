defmodule Changelog.SponsorStyle do
  def all do
    [
      %{type: "Team Culture", name: "Indeed Assesments, Darren Nix", audio: "https://changelog-assets.s3.amazonaws.com/podcast-ad-examples/indeed-darren-001.mp3", duration: 141},
      %{type: "Team Culture", name: "Indeed Assesments, Bryan Chaney", audio: "https://changelog-assets.s3.amazonaws.com/podcast-ad-examples/indeed-bryan-001.mp3", duration: 126},
      %{type: "Partner pre-roll", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-partner-preroll-move-fast-and-fix-things.mp3", duration: 5},
      %{type: "Customer story", name: "CircleCI: Paul Biggar", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-circleci-1.mp3", duration: 63},
      %{type: "Endorsement", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-move-fast-and-fix-things.mp3", duration: 33}
    ]
  end
end
