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
alias Changelog.{Person, Podcast}

# People

Repo.insert! %Person{
  name: "Adam Stacoviak",
  email: "adam@stacoviak.com",
  handle: "adamstac",
  twitter_handle: "adamstac",
  github_handle: "adamstac",
  bio: "Founder & Editor-in-Chief of @Changelog",
  website: "http://adamstacoviak.com/",
  admin: true
}

Repo.insert! %Person{
  name: "Jerod Santo",
  email: "jerod.santo@gmail.com",
  handle: "jerodsanto",
  twitter_handle: "jerodsanto",
  github_handle: "jerodsanto",
  bio: "Professional `binding.pry` typer. Also @changelog, @objectlateral, @interfaceschool",
  website: "http://jerodsanto.net/",
  admin: true
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
  schedule_note: "New show every Friday!"
}

founderstalk = Repo.insert! %Podcast{
  name: "Founders Talk",
  slug: "founderstalk",
  status: 2,
  description: "An interview podcast, featuring in-depth, one on one, conversations with Founders.",
  itunes_url: "https://itunes.apple.com/us/podcast/founders-talk/id396900791?mt=2"
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
  schedule_note: "Records LIVE every Thursday at 12pm PST!"
}

rfc = Repo.insert! %Podcast{
  name: "Request for Commits",
  slug: "rfc",
  status: 2,
  description: "Exploring different perspectives in open source sustainability. It's about the human side of code.",
  itunes_url: "https://itunes.apple.com/us/podcast/request-for-commits/id1141345001?mt=2"
}
