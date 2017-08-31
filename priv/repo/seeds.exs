# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Changelog.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Changelog.Repo
alias Changelog.{Channel, Episode, EpisodeChannel, EpisodeGuest, EpisodeHost,
                 EpisodeSponsor, Person, Podcast, PodcastHost, Post,
                 PostChannel, Sponsor}

# Clean slate

Repo.delete_all EpisodeChannel
Repo.delete_all PostChannel
Repo.delete_all Channel
Repo.delete_all EpisodeSponsor
Repo.delete_all EpisodeGuest
Repo.delete_all EpisodeHost
Repo.delete_all Episode
Repo.delete_all PodcastHost
Repo.delete_all Podcast
Repo.delete_all Post
Repo.delete_all Person
Repo.delete_all Sponsor

# People

adamstac = Repo.insert! %Person{
  name: "Adam Stacoviak",
  email: "adam@stacoviak.com",
  handle: "adamstac",
  twitter_handle: "adamstac",
  github_handle: "adamstac",
  bio: "Founder & Editor-in-Chief of @Changelog",
  website: "http://adamstacoviak.com/",
  admin: true
}

jerodsanto = Repo.insert! %Person{
  name: "Jerod Santo",
  email: "jerod.santo@gmail.com",
  handle: "jerodsanto",
  twitter_handle: "jerodsanto",
  github_handle: "jerodsanto",
  bio: "Professional `binding.pry` typer. Also @changelog, @objectlateral, @interfaceschool",
  website: "http://jerodsanto.net/",
  admin: true
}

carlisia = Repo.insert! %Person{
  name: "Carlisia Pinto",
  email: "carlisia@changelog.com",
  handle: "carlisia",
  twitter_handle: "carlisia",
  github_handle: "carlisia",
  bio: "Distributing all your systems @fastly • #golang dev • @golangbridge • @remotemeetupGo • co-host of @GoTimeFM • runner",
  website: "https://keybase.io/carlisia"
}

erikstmartin = Repo.insert! %Person{
  name: "Erik St. Martin",
  email: "erikstmartin@changelog.com",
  handle: "erikstmartin",
  twitter_handle: "erikstmartin",
  github_handle: "erikstmartin",
  bio: "@GopherCon Organizer, Co-author Go in Action, Co-founder @GopherAcademy, Co-host @gotimefm, Kubernetes / Container fanatic"
}

bketelsen = Repo.insert! %Person{
  name: "Brian Ketelsen",
  email: "bketelsen@gmail.com",
  handle: "bketelsen",
  twitter_handle: "bketelsen",
  github_handle: "bketelsen",
  bio: "@GopherCon Organizer, Co-author Go in Action, Co-founder @GopherAcademy, Co-host @gotimefm, Kubernetes / Container fanatic",
  website: "http://www.brianketelsen.com"
}

nayafia = Repo.insert! %Person{
  name: "Nadia Eghbal",
  email: "nadia.eghbal@gmail.com",
  handle: "nayafia",
  twitter_handle: "nayafia",
  github_handle: "nayafia",
  bio: "Subtle + overt = subvert",
  website: "http://nadiaeghbal.com/"
}

mikeal = Repo.insert! %Person{
  name: "Mikeal Rogers",
  email: "mikeal.rogers@gmail.com",
  handle: "mikeal",
  twitter_handle: "mikeal",
  github_handle: "mikeal",
  bio: "Community Organizer @ Node.js Foundation. Creator of request, NodeConf, lots of thing. Co-host of the RFC podcast.",
  website: "http://mikealrogers.com/"
}

# Guests

jasnell = Repo.insert! %Person{
  name: "James M Snell",
  email: "jasnell@gmail.com",
  handle: "jasnell",
  twitter_handle: "jasnell",
  github_handle: "jasnell",
  website: "http://www.chmod777self.com/"
}

davegandy = Repo.insert! %Person{
  name: "Dave Gandy",
  email: "dave@davegandy.com",
  handle: "davegandy",
  twitter_handle: "davegandy",
  github_handle: "davegandy",
  website: "http://fontawesome.io/"
}

soffes = Repo.insert! %Person{
  name: "Sam Soffes",
  email: "sam@soff.es",
  handle: "soffes",
  twitter_handle: "soffes",
  github_handle: "soffes",
  bio: "Software engineer living in San Francisco.",
  website: "https://soff.es/"
}

heathermeeker = Repo.insert! %Person{
  name: "Heather Meeker",
  email: "hmeeker@omm.com",
  handle: "heathermeeker",
  bio: " Specialist in open source software licensing.",
  website: "https://heathermeeker.com/"
}

tessr = Repo.insert! %Person{
  name: "Tess Rinearson",
  email: "hello@tes.sr",
  handle: "tessr",
  twitter_handle: "_tessr",
  github_handle: "tessr",
  bio: "Software engineer at Chain. I attended the University of Pennsylvania and Carnegie Mellon University before dropping out to join Medium.",
  website: "http://tes.sr/"
}

andrewgodwin = Repo.insert! %Person{
  name: "Andrew Godwin",
  email: "andrew@aeracode.org",
  handle: "andrewgodwin",
  twitter_handle: "andrewgodwin",
  github_handle: "andrewgodwin",
  bio: "A programmer (of Python, Django, and plenty of other languages depending on the situation), a British expat who now lives in mostly-sunny San Francisco, a reasonably well-travelled technical public speaker, and an alumnus of Magdalen College, Oxford.",
  website: "http://www.aeracode.org/"
}

# Channels

practice = Repo.insert! %Channel{
  name: "Practice",
  slug: "practice",
  description: "Description for the practice channel"
}

updates = Repo.insert! %Channel{
  name: "Updates",
  slug: "updates",
  description: "Description for the updates channel"
}

# Podcasts

changelog = Repo.insert! %Podcast{
  name: "The Changelog",
  slug: "podcast",
  status: 2,
  description: "A weekly podcast that shines a spotlight on the technology and people of open source. It's about the code, the people, and the community.",
  twitter_handle: "changelog",
  itunes_url: "https://itunes.apple.com/us/podcast/the-changelog/id341623264?mt=2",
  ping_url: "https://github.com/thechangelog/ping",
  schedule_note: "New show every Friday!",
  podcast_hosts: [
    %PodcastHost{
      position: 1,
      person: adamstac
    },
    %PodcastHost{
      position: 2,
      person: jerodsanto
    }
  ]
}

gotime = Repo.insert! %Podcast{
  name: "Go Time",
  slug: "gotime",
  status: 2,
  description: "A weekly panelist podcast discussing the Go programming language, the community, and everything in between.",
  vanity_domain: "gotime.fm",
  twitter_handle: "gotimefm",
  itunes_url: "https://itunes.apple.com/us/podcast/go-time/id1120964487?mt=2",
  ping_url: "https://github.com/gotimefm/ping",
  schedule_note: "Records LIVE every Thursday at 12pm PST!",
  podcast_hosts: [
    %PodcastHost{
      position: 1,
      person: erikstmartin
    },
    %PodcastHost{
      position: 2,
      person: carlisia
    },
    %PodcastHost{
      position: 3,
      person: bketelsen
    }
  ]
}

rfc = Repo.insert! %Podcast{
  name: "Request for Commits",
  slug: "rfc",
  status: 2,
  description: "Exploring different perspectives in open source sustainability. It's about the human side of code.",
  itunes_url: "https://itunes.apple.com/us/podcast/request-for-commits/id1141345001?mt=2",
  podcast_hosts: [
    %PodcastHost{
      position: 1,
      person: nayafia
    },
    %PodcastHost{
      position: 2,
      person: mikeal
    }
  ]
}

founderstalk = Repo.insert! %Podcast{
  name: "Founders Talk",
  slug: "founderstalk",
  status: 2,
  description: "An interview podcast, featuring in-depth, one on one, conversations with Founders.",
  itunes_url: "https://itunes.apple.com/us/podcast/founders-talk/id396900791?mt=2",
  podcast_hosts: [
    %PodcastHost{
      position: 1,
      person: adamstac
    }
  ]
}

# Sponsors

toptal = Repo.insert! %Sponsor{
  name: "TopTal",
  description: "Toptal is an exclusive network of the top freelance software developers, designers, and finance experts in the world.
Top companies rely on Toptal freelancers for their most important projects.",
  website: "https://www.toptal.com/",
  twitter_handle: "toptal"
}

hackerparadise = Repo.insert! %Sponsor{
  name: "Hacker Paradisse",
  description: "Travel the world. Build cool things. Meet awesome people.",
  website: "http://www.hackerparadise.org/",
  twitter_handle: "hackerparadise"
}

gocd = Repo.insert! %Sponsor{
  name: "GoCD",
  description: "Simplify Continuous Delivery: Open source continuous delivery server to model and visualize complex workflows with ease.",
  website: "https://www.go.cd/",
  github_handle: "gocd",
  twitter_handle: "goforcd"
}

rollbar = Repo.insert! %Sponsor{
  name: "Rollbar",
  description: "Rollbar helps engineering teams stay focused, be more productive and deliver exceptional error-free experiences.",
  website: "https://rollbar.com/",
  github_handle: "rollbar",
  twitter_handle: "rollbar"
}

linode = Repo.insert! %Sponsor{
  name: "Linode",
  description: "Cloud Hosting for Developers: High performance SSD Linux servers for all of your infrastructure needs.",
  website: "https://linode.com/",
  github_handle: "linode",
  twitter_handle: "linode"
}

codeschool = Repo.insert! %Sponsor{
  name: "Code School",
  description: "Learn by Doing: Interactive programming courses and guided projects.",
  website: "https://www.codeschool.com/",
  twitter_handle: "codeschool"
}

# Podcast Episodes with stub audio file

audio_file = %{file_name: "web/static/assets/california.mp3", updated_at: Ecto.DateTime.utc}

Repo.insert! %Episode{
  slug: "226",
  title: "The Road to Font Awesome 5 with Dave Gandy",
  summary: "Dave Gandy joined the show to talk about the history of Font Awesome, what's to come in Font Awesome 5 and their Kickstarter to fund Font Awesome 5 Pro, and how everything they're doing is funneling back into the forever free and open source — Font Awesome Free.",
  notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus molestie ut lorem vitae feugiat. Pellentesque vel erat libero. Vivamus rhoncus non erat nec bibendum. Vivamus ullamcorper massa mauris, at dapibus metus tincidunt sit amet. Suspendisse eu nibh vitae libero consectetur vehicula non a dolor. Aenean quis ligula ut risus iaculis blandit.",
  published: true,
  published_at: Timex.now,
  recorded_at: Timex.now,
  bytes: 1234,
  duration: 6840,
  podcast: changelog,
  audio_file: audio_file,
  episode_guests: [
    %EpisodeGuest{
      position: 1,
      person: davegandy
    }
  ],
  episode_hosts: [
    %EpisodeHost{
      position: 1,
      person: adamstac
    }
  ],
  episode_sponsors: [
    %EpisodeSponsor{
      position: 1,
      sponsor: codeschool,
      title: "Code School",
      link_url: "https://www.codeschool.com/changelog",
      description: "Learn to program by doing with hands-on courses. Save $10 per month! Sign up for Code School for only $19 per month by using our special URL [codeschool.com/changelog](https://www.codeschool.com/changelog)."
    },
    %EpisodeSponsor{
      position: 2,
      sponsor: linode,
      title: "Linode",
      link_url: "https://linode.com/rfc",
      description: "*Our cloud server of choice!* Get one of the fastest, most efficient SSD cloud servers for only $10/mo. We host everything we do on Linode servers. Use the code `changelog20` to get 2 months free!"
    },
    %EpisodeSponsor{
      position: 3,
      sponsor: rollbar,
      title: "Rollbar",
      link_url: "https://rollbar.com/changelog",
      description: "Put errors in their place! Full-stack error tracking for all apps in any language. "
    }
  ]
}

Repo.insert! %Episode{
  slug: "229",
  title: "Python, Django, and Channels",
  summary: "Django core contributor Andrew Godwin joins the show to tell us all about Python and Django. If you've ever wondered why people love Python, what Django's virtues are as a web framework, or how Django Channels measure up to Phoenix's Channels and Rails' Action Cable, this is the show for you. Also: Andrew's take on funding and sustaining open source efforts.",
  notes: "This episode started on Ping.",
  published: true,
  published_at: Timex.now,
  recorded_at: Timex.now,
  bytes: 1234,
  duration: 6840,
  podcast: changelog,
  audio_file: audio_file,
  episode_guests: [
    %EpisodeGuest{
      position: 1,
      person: andrewgodwin
    }
  ],
  episode_hosts: [
    %EpisodeHost{
      position: 1,
      person: adamstac
    },
    %EpisodeHost{
      position: 2,
      person: jerodsanto
    }
  ],
  episode_sponsors: [
    %EpisodeSponsor{
      position: 1,
      sponsor: gocd,
      title: "GoCD",
      link_url: "https://www.go.cd/changelog",
      description: "GoCD is an on-premise open source continuous delivery server created by ThoughtWorks that lets you automate and streamline your build-test-release cycle for reliable, continuous delivery of your product. "
    },
    %EpisodeSponsor{
      position: 2,
      sponsor: toptal,
      title: "TopTal",
      link_url: "http://www.toptal.com/?utm_source=changelog&utm_medium=podcast&utm_campaign=changelog-sponsorship",
      description: "Scale your team and hire the top 3% of developers and designers at Toptal. Email Adam at `adam@changelog.com` for a personal introduction to Toptal."
    }
  ]
}

Repo.insert! %Episode{
  slug: "231",
  title: "HTTP/2 in Node.js Core",
  summary: "In this special episode recorded at Node Interactive 2016 in Austin, TX Adam talked with James Snell (IBM Technical Lead for Node and member of Node's TSC and CTC) about the work he's doing on Node's implementation of http2, the state of http2 in Node, what this new spec has to offer, and what the Node community can expect from this new protocol.",
  notes: "This episode is a preview of our upcoming \"Future of Node.js\" series recorded at Node Interactive 2016 in Austin, TX. The series is produced in partnership with Node.js Foundation and sponsored by IBM. We'll be releasing the full series soon on our new podcast \"Spotlight\". If you haven't subscribed to Changelog Master yet, which includes all the podcasts we produce, now would be a good time to do so. You can also subscribe to Changelog Weekly where we announce all the new things we're up to.",
  published: true,
  published_at: Timex.now,
  recorded_at: Timex.now,
  bytes: 1234,
  duration: 6840,
  podcast: changelog,
  audio_file: audio_file,
  episode_guests: [
    %EpisodeGuest{
      position: 1,
      person: jasnell
    }
  ],
  episode_hosts: [
    %EpisodeHost{
      position: 1,
      person: adamstac
    }
  ],
  episode_sponsors: [
    %EpisodeSponsor{
      position: 1,
      sponsor: rollbar,
      title: "Rollbar",
      link_url: "https://rollbar.com/changelog",
      description: "Put errors in their place! `npm install --save rollbar` for error tracking in your Node.js apps."
    },
    %EpisodeSponsor{
      position: 2,
      sponsor: hackerparadise,
      title: "Hacker Paradise",
      link_url: "http://www.hackerparadise.org/changelog",
      description: "Do you want to spend a month in South America, expenses paid, working on open source? We teamed up with Hacker Paradise to offer two Open Source Fellowships for a month on one of their upcoming trips to either Argentina or Peru. "
    },
    %EpisodeSponsor{
      position: 3,
      sponsor: gocd,
      title: "GoCD",
      link_url: "https://www.go.cd/changelog",
      description: "GoCD is an on-premise open source continuous delivery server created by ThoughtWorks that lets you automate and streamline your build-test-release cycle for reliable, continuous delivery of your product. "
    }
  ]
}

Repo.insert! %Episode{
  slug: "51",
  title: "Sam Soffes / Onward",
  summary: "TCould this be Sam's final appearance on Founders Talk? Only time will tell.",
  notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus molestie ut lorem vitae feugiat. Pellentesque vel erat libero. Vivamus rhoncus non erat nec bibendum. Vivamus ullamcorper massa mauris, at dapibus metus tincidunt sit amet. Suspendisse eu nibh vitae libero consectetur vehicula non a dolor. Aenean quis ligula ut risus iaculis blandit.",
  published: true,
  published_at: Timex.now,
  recorded_at: Timex.now,
  bytes: 1234,
  duration: 6840,
  podcast: founderstalk,
  audio_file: audio_file,
  episode_guests: [
    %EpisodeGuest{
      position: 1,
      person: soffes
    }
  ],
  episode_hosts: [
    %EpisodeHost{
      position: 1,
      person: adamstac
    }
  ]
}

Repo.insert! %Episode{
  slug: "23",
  title: "Open Sourcing Chain's Developer Platform with Tess Rinearson",
  summary: "Tess Rinearson joined the show to talk about Chain launching their open source developer platform, choosing an open source license, open sourcing Chain Core, and the future of this powerful blockchain written in Go.",
  notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus molestie ut lorem vitae feugiat. Pellentesque vel erat libero. Vivamus rhoncus non erat nec bibendum. Vivamus ullamcorper massa mauris, at dapibus metus tincidunt sit amet. Suspendisse eu nibh vitae libero consectetur vehicula non a dolor. Aenean quis ligula ut risus iaculis blandit.",
  published: true,
  published_at: Timex.now,
  recorded_at: Timex.now,
  bytes: 1234,
  duration: 6840,
  podcast: gotime,
  audio_file: audio_file,
  episode_guests: [
    %EpisodeGuest{
      position: 1,
      person: tessr
    }
  ],
  episode_hosts: [
    %EpisodeHost{
      position: 1,
      person: erikstmartin
    },
    %EpisodeHost{
      position: 2,
      person: carlisia
    },
    %EpisodeHost{
      position: 3,
      person: bketelsen
    },
  ],
  episode_sponsors: [
    %EpisodeSponsor{
      position: 1,
      sponsor: linode,
      title: "Linode",
      link_url: "https://linode.com/rfc",
      description: "*Our cloud server of choice!* Get one of the fastest, most efficient SSD cloud servers for only $10/mo. We host everything we do on Linode servers. Use the code `rfc20` to get 2 months free!"
    },
    %EpisodeSponsor{
      position: 2,
      sponsor: codeschool,
      title: "Code School",
      link_url: "https://www.codeschool.com/go",
      description: "On Track With Go — Learn what makes Go a great fit for concurrent programs and how you can use it to leverage the power of modern computer architectures in this new course for those getting started with Go."
    }
  ]
}

Repo.insert! %Episode{
  slug: "9",
  title: "Open Source & Licenses with Heather Meeker",
  summary: "Heather Meeker joined the show to talk about open source licensing, why open source licenses are historically significant, how much developers really need to know, and how much developers think they know. We also talk about mixing commercial and open source licenses, and how lawyers keep up with an ever-changing landscape.",
  notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus molestie ut lorem vitae feugiat. Pellentesque vel erat libero. Vivamus rhoncus non erat nec bibendum. Vivamus ullamcorper massa mauris, at dapibus metus tincidunt sit amet. Suspendisse eu nibh vitae libero consectetur vehicula non a dolor. Aenean quis ligula ut risus iaculis blandit.",
  published: true,
  published_at: Timex.now,
  recorded_at: Timex.now,
  bytes: 1234,
  duration: 6840,
  podcast: rfc,
  audio_file: audio_file,
  episode_guests: [
    %EpisodeGuest{
      position: 1,
      person: heathermeeker
    }
  ],
  episode_hosts: [
    %EpisodeHost{
      position: 1,
      person: nayafia
    },
    %EpisodeHost{
      position: 2,
      person: mikeal
    }
  ],
  episode_sponsors: [
    %EpisodeSponsor{
      position: 1,
      sponsor: toptal,
      title: "TopTal",
      link_url: "http://www.toptal.com/?utm_source=changelog&utm_medium=podcast&utm_campaign=changelog-sponsorship",
      description: "Scale your team and hire the top 3% of developers and designers at Toptal. Email Adam at `adam@changelog.com` for a personal introduction to Toptal."
    },
    %EpisodeSponsor{
      position: 2,
      sponsor: linode,
      title: "Linode",
      link_url: "https://linode.com/rfc",
      description: "*Our cloud server of choice!* Get one of the fastest, most efficient SSD cloud servers for only $10/mo. We host everything we do on Linode servers. Use the code `rfc20` to get 2 months free!"
    }
  ]
}

# Posts

Repo.insert! %Post{
  title: "Introducing Changelog 2.0",
  slug: "introducing-changelog-2-0",
  published: true,
  published_at: Timex.to_datetime({{2016, 10, 11}, {11, 25, 00}}, :local),
  author: adamstac,
  tldr: "**I'm excited to finally be able to introduce you to Changelog 2.0! This might seem like a simple visual update, but trust me when I tell you this is literally the biggest launch we’ve ever done.**

tl;dr — We launched a new brand and CMS to power the future of our digital media company.",
  body: "## The New Logo

There is so much in a logo. It carries the weight of all you do. It goes before you to set the tone for how you will be perceived. It represents you when you can't be directly involved. It's what people attach their feelings to. It's the sticker on a laptop representing an affinity or belief.

For 7 years, we have been primarily known as \"The Changelog podcast\" and our album art is that sticker on a listener's laptop — so we couldn't just carelessly make changes to our logo. We needed to seek out the right help and guidance through the process.

Nearly one year ago we began the process of rebranding The Changelog. But before we get to that, more than two years ago we purchased `changelog.com` for $1,000 in hope of one day taking the [advice of JT](https://www.youtube.com/watch?v=k06fsS9Vjn4) to drop the \"The.\" It’s cleaner.

We are now simply, Changelog.",
  post_channels: [
    %PostChannel{
      position: 1,
      channel: updates
    }
  ]
}

Repo.insert! %Post{
  title: "Changelog.com is Open Source",
  slug: "changelog-is-open-source",
  published: true,
  published_at: Timex.to_datetime({{2016, 10, 25}, {16, 45, 30}}, :local),
  author: jerodsanto,
  tldr: "This morning we open sourced the code that powers the new Changelog.com!",
  body: "As we promised in [our relaunch announcement](/posts/introducing-changelog-2-0), this morning we open sourced the code that powers the new Changelog.com!

Don't want the full rundown? Go star [the source code on GitHub](https://github.com/thechangelog/changelog.com).",
  post_channels: [
    %PostChannel{
      position: 1,
      channel: updates
    }
  ]
}

Repo.insert! %Post{
  title: "Slow Down to Go Faster",
  slug: "slow-down-to-go-faster",
  published: true,
  published_at: Timex.to_datetime({{2016, 11, 25}, {10, 30, 00}}, :local),
  author: jerodsanto,
  tldr: "What many people fail to realize — and what I’ll emphasize in this post — is that the compromises we often make when optimizing for development speed can actually slow us down.",
  body: "***Editor's Note:*** I originally wrote this for Fuel Your Coding back in October of 2010. Unfortunately, that site is now defunct, so I'm republishing the article here for posterity's sake1. I considered updating it for modern times, but I think it holds up well enough as is. Enjoy.
- - -
Today’s software development culture promotes [rapid development methodologies](http://en.wikipedia.org/wiki/Rapid_application_development), [minimum viable products](http://en.wikipedia.org/wiki/Minimum_viable_product), releasing early & often, and the axiom that [\"real artists ship\"](http://www.folklore.org/StoryView.py?story=Real_Artists_Ship.txt). What common thread weaves its way through all of these things?

**SPEED.**

If you haven’t felt the pressure to squeeze one more feature in before the release date, to fix an interface bug “RIGHT NOW!”, to get your product launched before your competition, or to shave a week off of your development schedule then you haven’t been developing software for all that long.

What many people fail to realize — and what I’ll emphasize in this post — is that the compromises we often make when optimizing for development speed can actually slow us down. More succinctly:

<mark>If you want to move faster, you have to slow down.</mark>

Allow me to demonstrate this concept in a few key areas of software development.",
  post_channels: [
    %PostChannel{
      position: 1,
      channel: practice
    }
  ]
}

Repo.insert! %Post{
  title: "This is a draft",
  slug: "this-is-a-draft",
  published: false,
  published_at: Timex.now,
  author: adamstac,
  tldr: "Not published yet, But it will be awesome. All the new tech people are raging about!",
  body: "This is content that will be published soon. For now it is just sitting, waiting, wishing – in the database.",
  post_channels: [
    %PostChannel{
      position: 1,
      channel: practice
    }
  ]
}
