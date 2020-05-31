# This should be CNAME, but then only one of these can exist
# Need to define it as a TXT record so that we can have multiple challenges, e.g. certbot, not just Fastly
resource "dnsimple_record" "fastly_acme_challenge" {
  domain = "changelog.com"
  name = "_acme-challenge"
  value = "9zucpyar6lghz8x48b.fastly-validations.com"
  type = "TXT"
  ttl = 60
}
resource "dnsimple_record" "certbot_acme_challenge_1" {
  domain = "changelog.com"
  name = "_acme-challenge"
  value = "cpVuT2hvGOhWLabkRBPg1_slVw2MhrywjIhy9wW-Epo"
  type = "TXT"
  ttl = 60
}
resource "dnsimple_record" "certbot_acme_challenge_2" {
  domain = "changelog.com"
  name = "_acme-challenge"
  value = "1JQRyW3JKd6geD4VbvE-sMAP_ckdy0IVhSRYyZqeDhI"
  type = "TXT"
  ttl = 60
}

resource "dnsimple_record" "netdata_changelog_com" {
  domain = "changelog.com"
  name = "netdata"
  value = "http://201910i.changelog.com:19999/"
  type = "URL"
  ttl = 60
}

resource "dnsimple_record" "apex-changelog_com" {
  domain = "changelog.com"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv4
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "apex-changelog_com_ipv6" {
  domain = "changelog.com"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv6
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "www_changelog_com" {
  domain = "changelog.com"
  name = "www"
  value = linode_nodebalancer.prod_2019_10.ipv4
  type = "A"
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
  value = linode_nodebalancer.prod_2019_10.ipv6
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
  value = "https://circleci.com/gh/thechangelog/changelog.com"
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

resource "dnsimple_record" "apex-changelog_fm" {
  domain = "changelog.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv4
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "apex-changelog_fm_ipv6" {
  domain = "changelog.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv6
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "apex-gotime_fm" {
  domain = "gotime.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv4
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "apex-gotime_fm_ipv6" {
  domain = "gotime.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv6
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "apex-jsparty_fm" {
  domain = "jsparty.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv4
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "apex-jsparty_fm_ipv6" {
  domain = "jsparty.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv6
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "apex-rfc_fm" {
  domain = "rfc.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv4
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "apex-rfc_fm_ipv6" {
  domain = "rfc.fm"
  name = ""
  value = linode_nodebalancer.prod_2019_10.ipv6
  type = "AAAA"
  ttl = 60
}
