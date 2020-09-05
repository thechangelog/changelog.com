# TODO: manage by external-dns

resource "dnsimple_record" "apex-changelog_com_ipv6" {
  domain = "changelog.com"
  name = ""
  value = "2600:3c03:1::2d4f:f74d"
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "cdn_changelog_com" {
  domain = "changelog.com"
  name = "cdn"
  value = "dualstack.changelog.map.fastly.net"
  type = "CNAME"
  ttl = 60
}

resource "dnsimple_record" "www_changelog_com_ipv6" {
  domain = "changelog.com"
  name = "www"
  value = "2600:3c03:1::2d4f:f74d"
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "code_changelog_com" {
  domain = "changelog.com"
  name = "code"
  value = "https://github.com/thechangelog/changelog.com"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "secrets_changelog_com" {
  domain = "changelog.com"
  name = "secrets"
  value = "https://lastpass.com/?&ac=1"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "dns_changelog_com" {
  domain = "changelog.com"
  name = "dns"
  value = "https://dnsimple.com/a/10898/domains/changelog.com/dns"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "ci_changelog_com" {
  domain = "changelog.com"
  name = "ci"
  value = "https://app.circleci.com/pipelines/github/thechangelog/changelog.com"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "errors_changelog_com" {
  domain = "changelog.com"
  name = "errors"
  value = "https://rollbar.com/changelogmedia/changelog.com/"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "docker_changelog_com" {
  domain = "changelog.com"
  name = "docker"
  value = "https://hub.docker.com/u/thechangelog"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "logs_changelog_com" {
  domain = "changelog.com"
  name = "logs"
  value = "https://papertrailapp.com/systems/2019/"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "monitoring_changelog_com" {
  domain = "changelog.com"
  name = "monitoring"
  value = "https://my.pingdom.com/reports/uptime#daterange=7days&tab=uptime_tab&check=2310619"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "apex-changelog_fm_ipv6" {
  domain = "changelog.fm"
  name = ""
  value = "2600:3c03:1::2d4f:f74d"
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "apex-jsparty_fm_ipv6" {
  domain = "jsparty.fm"
  name = ""
  value = "2600:3c03:1::2d4f:f74d"
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "apex-gotime_fm_ipv6" {
  domain = "gotime.fm"
  name = ""
  value = "2600:3c03:1::2d4f:f74d"
  type = "AAAA"
  ttl = 60
}
