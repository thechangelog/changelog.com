#!/usr/bin/env bash

FQDN="${FQDN:-changelog.com}"
IPv4="${IPv4:-$(dig +short -4 "$FQDN")}"

get() {
  # shellcheck disable=SC2068
  curl --verbose --silent $@
}

@test "fqdn http" {
  get "http://$FQDN" |
    grep "News and podcasts for developers | Changelog"
}

@test "fqdn https" {
  [ "$IPv4" != "127.0.0.1" ] ||
    skip "HTTPS is not configured for $IPv4"

  get "https://$FQDN" |
    grep "News and podcasts for developers | Changelog"
}

@test "nginx default_server" {
  get "http://$IPv4" |
    grep "News and podcasts for developers | Changelog"
}

@test "legacy assets" {
  get "http://$FQDN/wp-content/uploads/changelog-nightly-2015-03-08-night-1024x890.png"
}

@test "posts redirects" {
  run get "http://$FQDN/day-one-recap-gophercon-2016"
  echo "$output" |
    grep "Location: http://$FQDN/posts/day-one-recap-gophercon-2016"
}

@test "changelog.fm" {
  get --resolve "changelog.fm:80:$IPv4" "http://changelog.fm" 2>&1 |
    grep "Location: http://changelog.com/podcast/"
}

@test "gotime.fm" {
  get --resolve "gotime.fm:80:$IPv4" "http://changelog.fm" 2>&1 |
    grep "Location: http://changelog.com/podcast/"
}

@test "jsparty.fm" {
  get --resolve "gotime.fm:80:$IPv4" "http://changelog.fm" 2>&1 |
    grep "Location: http://changelog.com/podcast/"
}

@test "rfc.fm" {
  get --resolve "gotime.fm:80:$IPv4" "http://changelog.fm" 2>&1 |
    grep "Location: http://changelog.com/podcast/"
}

@test "nginx_status is forbidden" {
  get "http://$FQDN/nginx_status" 2>&1 |
    grep "403 Forbidden"
}
