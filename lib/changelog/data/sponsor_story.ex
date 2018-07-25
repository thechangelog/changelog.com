defmodule Changelog.SponsorStory do
  defstruct [:sponsor, :slug, :logo, :quote, :examples, :content_md]

  def all, do: [rollbar()]

  def get_by_slug(slug) do
    try do
      apply(__MODULE__, String.to_existing_atom(slug), [])
    rescue
      _all -> rollbar()
    end
  end

  def rollbar do
    %__MODULE__{
      sponsor: "Rollbar",
      slug: "rollbar",
      logo: "rollbar.png",
      quote: %{
        name: "Mike Smith",
        content: "Partnering with Changelog on their news and podcasts have helped me to build brand awareness for Rollbar in a space where developers have heard the 'you need error tracking' message before. Adam and his team do an amazing job at finding the stories about our brand and service that developers want to hear. They're so good at getting the attention (and the trust) of their listeners.",
        image: "mike-smith.jpg",
        title: "Head of Growth at Rollbar"
      },
      examples: [
        %{type: "Partner pre-roll", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/site-sponsors-rollbar-partner-preroll-move-fast-and-fix-things.mp3", duration: 5},
        %{type: "Customer story", name: "CircleCI: Paul Biggar", audio: "https://changelog-assets.s3.amazonaws.com/site-sponsors-rollbar-adroll-circleci-1.mp3", duration: 63},
        %{type: "Endorsement", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/site-sponsors-rollbar-adroll-move-fast-and-fix-things.mp3", duration: 33}
      ],
      content_md: """
      ### Who is Rollbar?

      Rollbar is an error monitoring platform that helps developer teams move fast and fix things. Catch errors before your users do. Resolve errors in minutes, and deploy your code with confidence.

      <blockquote>
        <p>Rollbar is our early warning system for errors. The worst thing that can happen is a customer writes in to the support team to say something is broken. Rollbar allows us to be ahead of our customers and to fix issues before they ever know something is wrong.</p>
        <footer>
          <strong>Tyler Wells</strong> — Twilio, Director of Engineering - <a href="https://rollbar.com/customers/twilio/">source</a>
        </footer>
      </blockquote>

      ### We helped Rollbar build brand awareness

      A few years back Rollbar started to focus on sponsoring conferences and communities. They'd go and setup an awesome booth, talk to the community, and do demos. At the time, not many people knew who Rollbar was or what they were about.

      Several months later at another conference, the same thing — great experience, great meeting with the community, but not many people knew about Rollbar. The next conference was different. The community was aware of Rollbar and what they offered developers. They were told by several members of the community who visited their booth that they heard about Rollbar because they sponsored some of their favorite podcasts. These folks weren't Rollbar users either. However, they did mention that they've recommended Rollbar to their developer friends. That was huge news! Because they sponsored many podcasts from Changelog's network; including The Changelog, JS Party, The React Podcast, and Go Time, Rollbar was able to gain clear brand awareness in the developer community.

      Don't underestimate the power of awareness for your brand! The brand awareness we've helped to develop for Rollbar is the foundation they've been able to build they developer marketing strategy upon.
      """
    }
  end
  def intel do
    %__MODULE__{
      sponsor: "Intel",
      slug: "intel",
      logo: "intel.png",
      quote: %{
        name: "Karl Fezer",
        content: "We partnered with Changelog on Practical AI to help foster conversations and communities across the landscape of Artificial Intelligence. Our ads on Practical AI have really helped to shape our AI story, how our customers are impacted impacted by our technology — we're even able to promote our teams and culture to attract the right talent. If you listen to Practical AI, that's a great start to being a fit here at Intel AI.",
        image: "karl-fezer.jpg",
        title: "AI Developer Community Manager at Intel AI"
      },
      examples: [
        %{type: "Endorsement", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/site-sponsors-rollbar-adroll-move-fast-and-fix-things.mp3", duration: 33}
      ],
      content_md: """
      """
    }
  end
  def linode do
    %__MODULE__{
      sponsor: "Linode",
      slug: "linode",
      logo: "linode.png",
      quote: %{
        name: "Karl Fezer",
        content: "We partnered with Changelog on Practical AI to help foster conversations and communities across the landscape of Artificial Intelligence. Our ads on Practical AI have really helped to shape our AI story, how our customers are impacted impacted by our technology — we're even able to promote our teams and culture to attract the right talent. If they listen to Practical AI, that's a great start to being the right person for Intel AI.",
        image: "karl-fezer.jpg",
        title: "AI Developer Community Manager at Intel AI"
      },
      examples: [
        %{type: "Endorsement", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/site-sponsors-rollbar-adroll-move-fast-and-fix-things.mp3", duration: 33}
      ],
      content_md: """
      """
    }
  end
  def fastly do
    %__MODULE__{
      sponsor: "Fastly",
      slug: "fastly",
      logo: "fastly.png",
      quote: %{
        name: "Elaine Greenburg",
        content: "Wow! Fastly gets to be the content delivery backbone Changelog builds everything upon. Plus, the Fastly brand and core value add can be heard in the pre-roll of every podcast episode. We couldn't have asked for a better partner to help us reach the developer community.",
        image: "elaine-greenburg.jpg",
        title: "Senior Communications Manager at Fastly"
      },
      examples: [
        %{type: "Endorsement", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/site-sponsors-rollbar-adroll-move-fast-and-fix-things.mp3", duration: 33}
      ],
      content_md: """
      """
    }
  end
  def datadog do
    %__MODULE__{
      sponsor: "Datadog",
      slug: "datadog",
      logo: "datadog.png",
      quote: %{
        name: "Leo Schramm",
        content: "We partnered with Changelog on Practical AI to help foster conversations and communities across the landscape of Artificial Intelligence. Our ads on Practical AI have really helped to shape our AI story, how our customers are impacted impacted by our technology — we're even able to promote our teams and culture to attract the right talent. If they listen to Practical AI, that's a great start to being the right person for Intel AI.",
        image: "karl-fezer.jpg",
        title: "Marketing Manager & Demand Gen at Datadog"
      },
      examples: [
        %{type: "Endorsement", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/site-sponsors-rollbar-adroll-move-fast-and-fix-things.mp3", duration: 33}
      ],
      content_md: """
      """
    }
  end
end
