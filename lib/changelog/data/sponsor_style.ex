defmodule Changelog.SponsorStyle do
  def all do
    [
      %{type: "Endorsment", name: "Linode, Zeus-like power", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/linode-zeus-like-power.mp3", duration: 30},
      %{type: "Endorsment", name: "Digital Ocean, Simplicity", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/digitalocean-simplicity-3.mp3", duration: 51},
      %{type: "Endorsment", name: "Raygun, APM for .NET", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/raygun-apm-1.mp3", duration: 72},
      %{type: "Insider", name: "Vettery, Talent executive", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/vettery-talent-exec-short.mp3", duration: 125},
      %{type: "Endorsment", name: "Datadog, overview (The Changelog)", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/datadog-2017-08-01-02.mp3", duration: 55},
      %{type: "Endorsement", name: "Datadog, overview (Go Time)", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/datadog-gotime-001.mp3", duration: 44},
      %{type: "Team Culture / Hiring", name: "Indeed, Darren Nix", audio: "https://changelog-assets.s3.amazonaws.com/podcast-ad-examples/indeed-darren-001.mp3", duration: 141},
      %{type: "Team Culture / Hiring", name: "Indeed, Bryan Chaney", audio: "https://changelog-assets.s3.amazonaws.com/podcast-ad-examples/indeed-bryan-001.mp3", duration: 126},
      %{type: "Endorsement", name: "Rollbar, Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/podcast-ad-examples/rollbar-move-fast-and-fix-things.mp3", duration: 33},
      %{type: "Partner pre-roll", name: "Rollbar, Network-wide pre-roll", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-partner-preroll-move-fast-and-fix-things.mp3", duration: 5},
      %{type: "Customer story", name: "Rollbar, CircleCI - Paul Biggar", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-circleci-1.mp3", duration: 63},
      %{type: "Partner Pre-roll", name: "Fastly, Network-wide pre-roll", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/fastly-preroll.mp3", duration: 06},
      %{type: "Endorsement", name: "Gauge, Open source test automation", audio: "https://changelog-assets.s3.amazonaws.com/podcast-ad-examples/gauge-jsparty.mp3", duration: 55},
      %{type: "Customer story", name: "Gliffy, How Plastiq uses Gliffy", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/gliffy-plastiq-004.mp3", duration: 163}
    ]
  end
end
