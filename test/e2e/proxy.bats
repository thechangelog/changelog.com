#!/usr/bin/env bash

FQDN="${FQDN:-changelog.com}"
IPv4="${IPv4:-$(dig +short -4 "$FQDN")}"

get() {
  # shellcheck disable=SC2068
  curl --verbose --silent $@
}

@test "changelog.com http" {
  get "http://$FQDN" |
    grep "News and podcasts for developers | Changelog"
}

@test "changelog.com https" {
  [ "$IPv4" != "127.0.0.1" ] ||
    skip "HTTPS is not configured for $IPv4"

  get "https://$FQDN" |
    grep "News and podcasts for developers | Changelog"
}

@test "default vhost is changelog.com" {
  get "http://$IPv4" |
    grep "News and podcasts for developers | Changelog"
}

@test "legacy assets http" {
  run get "http://$FQDN/wp-content/uploads/changelog-nightly-2015-03-08-night-1024x890.png"

  echo "$output" |
    grep "200 OK"
}

@test "legacy assets https" {
  [ "$IPv4" != "127.0.0.1" ] ||
    skip "HTTPS is not configured for $IPv4"

  run get "https://$FQDN/wp-content/uploads/changelog-nightly-2015-03-08-night-1024x890.png"

  echo "$output" |
    grep "200 OK"
}

@test "posts redirects" {
  run get "http://$FQDN/day-one-recap-gophercon-2016"

  echo "$output" |
    grep "Location: http://$FQDN/posts/day-one-recap-gophercon-2016"
}

@test "changelog.fm http-only" {
  get --resolve "changelog.fm:80:$IPv4" "http://changelog.fm" 2>&1 |
    grep "Location: http://changelog.com/podcast\s"
}

@test "gotime.fm http-only" {
  get --resolve "gotime.fm:80:$IPv4" "http://gotime.fm" 2>&1 |
    grep "Location: http://changelog.com/gotime\s"
}

@test "jsparty.fm http-only" {
  get --resolve "jsparty.fm:80:$IPv4" "http://jsparty.fm" 2>&1 |
    grep "Location: http://changelog.com/jsparty\s"
}

@test "rfc.fm http-only" {
  get --resolve "rfc.fm:80:$IPv4" "http://rfc.fm" 2>&1 |
    grep "Location: http://changelog.com/rfc\s"
}

@test "nginx_status is forbidden" {
  get "http://$FQDN/nginx_status" 2>&1 |
    grep "403 Forbidden"
}

@test "netdata http" {
  run get "http://netdata.$FQDN"

  echo "$output" |
    grep "netdata dashboard"

  echo "$output" |
    grep "Server: NetData Embedded HTTP Server"
}

@test "netdata https" {
  [ "$IPv4" != "127.0.0.1" ] ||
    skip "HTTPS is not configured for $IPv4"

  run get "http://netdata.$FQDN"

  echo "$output" |
    grep "netdata dashboard"

  echo "$output" |
    grep "Server: NetData Embedded HTTP Server"
}

