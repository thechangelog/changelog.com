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
alias Changelog.{Episode, EpisodeGuest, EpisodeHost, Person, Podcast, PodcastHost}

# Clean slate

Repo.delete_all EpisodeGuest
Repo.delete_all EpisodeHost
Repo.delete_all Episode
Repo.delete_all PodcastHost
Repo.delete_all Podcast
Repo.delete_all Person

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

# Podcast Episodes with stub audio file

audio_file = %{file_name: "web/static/assets/california.mp3", updated_at: Ecto.DateTime.utc}

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
  ]
}

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
  ]
}
