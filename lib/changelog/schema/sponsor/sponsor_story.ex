defmodule Changelog.SponsorStory do
  defstruct [:sponsor, :slug, :quote, :examples, :content_md]

  def all, do: [indeed()]

  @doc """
  Provides _just_ the example data for the given sponsors. This is used on
  /sponsor to display the podcast sponsorship example audio table.
  """
  def examples do
    [
      get_example(rollbar(), 0),
      get_example(rollbar(), 1),
      get_example(rollbar(), 2)
    ]
  end

  def get_by_slug(slug) do
    Enum.find(all(), rollbar(), &(&1.slug == slug))
  end

  def rollbar do
    %__MODULE__{
      sponsor: "Rollbar",
      slug: "rollbar",
      quote: %{
        name: "Mike Smith",
        content:
          "Partnering with Changelog on their news and podcasts have helped me to build brand awareness for Rollbar in a space where developers have heard the 'you need error tracking' message before. Adam and his team do an amazing job at finding the stories about our brand and service that developers want to hear. They're so good at getting the attention (and the trust) of their listeners.",
        image: "mike-smith.jpg",
        title: "Head of Growth at Rollbar"
      },
      examples: [
        %{
          type: "Partner preroll",
          name: "Move fast and fix things",
          audio:
            "https://cdn.changelog.com/partner-stories/rollbar-partner-preroll-move-fast-and-fix-things.mp3",
          duration: 5
        },
        %{
          type: "Customer story",
          name: "CircleCI: Paul Biggar",
          audio:
            "https://cdn.changelog.com/partner-stories/rollbar-circleci-1.mp3",
          duration: 63
        },
        %{
          type: "Endorsement",
          name: "Move fast and fix things",
          audio:
            "https://cdn.changelog.com/partner-stories/rollbar-move-fast-and-fix-things.mp3",
          duration: 33
        }
      ],
      content_md: """
      ## Who is Rollbar?

      Rollbar is an error monitoring platform that helps developer teams move fast and fix things. Catch errors before your users do. Resolve errors in minutes, and deploy your code with confidence.

      <blockquote>
        <p>Rollbar is our early warning system for errors. The worst thing that can happen is a customer writes in to the support team to say something is broken. Rollbar allows us to be ahead of our customers and to fix issues before they ever know something is wrong.</p>
        <footer>
          <strong>Tyler Wells</strong> — Twilio, Director of Engineering - <a href="https://rollbar.com/customers/twilio/">source</a>
        </footer>
      </blockquote>

      ## Who are you and what do you do at Rollbar?

      Hello, I'm Mike Smith. I lead growth and marketing here at Rollbar. Day to day I define and deploy growth and marketing strategies, meet with partners, review campaign results, and generally try to learn as much as I can about our customer.

      ## What do you value most about your partnership with Changelog?

      Changelog has been a huge factor in helping Rollbar build brand awareness in the developer community. A few years back we focused our efforts on sponsoring a few developer conferences and communities. We'd go and setup an awesome booth, talk to the community, do demos — at the time, not many people knew who we were or what our service was about.

      Several months later at another conference, the same thing — great experience, great meeting with the community, but not many people knew about us. To our suprise, the next conference was different. The community knew who we were and what value we offered developers. Several members of the community mentioned they heard about us because we sponsored some of their favorite podcasts. These folks weren't Rollbar users either. However, a few mentioned they have recommended Rollbar to their friends. That was great news and significant validation. Because we sponsored many Changelog podcasts; including The Changelog, JS Party, Founders Talk, and Go Time, Rollbar was able to gain clear and mesurable brand awareness in the developer community.

      ## Can you share some advice for future Changelog partners?

      Don't underestimate the power of brand awareness. We've gained so much brand awareness in the developer community (thanks to Changelog). That awareness has been the foundation we've built Rollbar's developer marketing strategy on.

      `---`

      Partner: Rollbar
      Website: [rollbar.com](https://rollbar.com/)
      Employees: 50
      ARR: $1,000,000
      """
    }
  end

  def indeed do
    %__MODULE__{
      sponsor: "Indeed",
      slug: "indeed",
      quote: %{
        name: "Travis Triggs",
        content:
          "Indeed is the #1 job site in the world with over 200 million unique visitors every month. Indeed strives to put job seekers first, giving them free access to search for jobs, post resumes, and research companies. Every day, they connect millions of people to new opportunities.",
        image: "travis-triggs.png",
        title: "Employer Brand Program Manager at Indeed.com"
      },
      examples: [
        %{
          type: "Team Culture",
          name: "Indeed Assesments, Darren Nix",
          audio:
            "https://cdn.changelog.com/podcast-ad-examples/indeed-darren-001.mp3",
          duration: 141
        },
        %{
          type: "Team Culture",
          name: "Indeed Assesments, Bryan Chaney",
          audio:
            "https://cdn.changelog.com/podcast-ad-examples/indeed-bryan-001.mp3",
          duration: 126
        }
      ],
      content_md: """
      """
    }
  end

  defp get_example(sponsor, index) do
    sponsor |> Map.get(:examples) |> Enum.at(index)
  end
end
