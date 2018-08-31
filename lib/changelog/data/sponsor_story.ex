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
      logo: "rollbar",
      quote: %{
        name: "Mike Smith",
        content: "Partnering with Changelog on their news and podcasts have helped me to build brand awareness for Rollbar in a space where developers have heard the 'you need error tracking' message before. Adam and his team do an amazing job at finding the stories about our brand and service that developers want to hear. They're so good at getting the attention (and the trust) of their listeners.",
        image: "mike-smith.jpg",
        title: "Head of Growth at Rollbar"
      },
      examples: [
        %{type: "Partner pre-roll", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-partner-preroll-move-fast-and-fix-things.mp3", duration: 5},
        %{type: "Customer story", name: "CircleCI: Paul Biggar", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-circleci-1.mp3", duration: 63},
        %{type: "Endorsement", name: "Move fast and fix things", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/rollbar-move-fast-and-fix-things.mp3", duration: 33}
      ],
      content_md: """
      ##### Who is Rollbar?

      Rollbar is an error monitoring platform that helps developer teams move fast and fix things. Catch errors before your users do. Resolve errors in minutes, and deploy your code with confidence.

      <blockquote>
        <p>Rollbar is our early warning system for errors. The worst thing that can happen is a customer writes in to the support team to say something is broken. Rollbar allows us to be ahead of our customers and to fix issues before they ever know something is wrong.</p>
        <footer>
          <strong>Tyler Wells</strong> — Twilio, Director of Engineering - <a href="https://rollbar.com/customers/twilio/">source</a>
        </footer>
      </blockquote>

      #### Who are you and what do you do at Rollbar?

      Hello, I'm Mike Smith. I lead growth and marketing here at Rollbar. Day to day I define and deploy growth and marketing strategies, meet with partners, review campaign results, and generally try to learn as much as I can about our customer.

      #### What do you value most about your partnership with Changelog?

      Changelog has been a huge factor in helping Rollbar build brand awareness in the developer community. A few years back we focused our efforts on sponsoring a few developer conferences and communities. We'd go and setup an awesome booth, talk to the community, do demos — at the time, not many people knew who we were or what our service was about.

      Several months later at another conference, the same thing — great experience, great meeting with the community, but not many people knew about us. To our suprise, the next conference was different. The community knew who we were and what value we offered developers. Several members of the community mentioned they heard about us because we sponsored some of their favorite podcasts. These folks weren't Rollbar users either. However, a few mentioned they have recommended Rollbar to their friends. That was great news and significant validation. Because we sponsored many Changelog podcasts; including The Changelog, JS Party, Founders Talk, and Go Time, Rollbar was able to gain clear and mesurable brand awareness in the developer community.

      #### Can you share some advice for future Changelog partners?

      Don't underestimate the power of brand awareness. We've gained so much brand awareness in the developer community (thanks to Changelog). That awareness has been the foundation we've built Rollbar's developer marketing strategy on.

      `---`

      Partner: Rollbar  
      Website: [rollbar.com](https://rollbar.com/)  
      Employees: 50  
      Annual Revenue: $1,000,000
      """
    }
  end
  def intel do
    %__MODULE__{
      sponsor: "Intel",
      slug: "intel",
      logo: "intel",
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
      logo: "linode",
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
      logo: "fastly",
      quote: %{
        name: "Elaine Greenburg",
        content: "Wow! Fastly gets to be the content delivery backbone Changelog builds everything upon. Plus, the Fastly brand and core value add can be heard in the pre-roll of every podcast episode. We couldn't have asked for a better partner to help us reach the developer community.",
        image: "elaine-greenburg.jpg",
        title: "Senior Communications Manager at Fastly"
      },
      examples: [
        %{type: "Partner Pre-roll", name: "Networkwide pre-roll sponsorship", audio: "https://changelog-assets.s3.amazonaws.com/partner-stories/fastly-preroll.mp3", duration: 06}
      ],
      content_md: """
      """
    }
  end
end
