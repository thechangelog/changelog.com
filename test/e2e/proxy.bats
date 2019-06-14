#!/usr/bin/env bash

load http

@test "http://changelog.com @ ${IPv4:?must be set} -> https://${FQDN:?must be set}" {
  run get --resolve "changelog.com:80:$IPv4" "http://changelog.com"

  echo "$output" |
    grep "location: https://$FQDN/\s"
}

@test "http://changelog.com @ $IPv4 X-Forwarded-Proto https" {
  run get --header "X-Forwarded-Proto: https" --resolve "changelog.com:80:$IPv4" "http://changelog.com"

  echo "$output" |
    grep "Changelog Media LLC"
}

@test "http://changelog.com/posts/the... @ $IPv4 -> https://$FQDN/posts/the..." {
  run get --resolve "changelog.com:80:$IPv4" "http://changelog.com/posts/the-new-changelog-setup-for-2019"

  echo "$output"

  echo "$output" |
    grep "location: https://$FQDN/posts/the-new-changelog-setup-for-2019\s"
}

@test "http://$FQDN legacy assets" {
  run get "http://$FQDN/wp-content/uploads/changelog-nightly-2015-03-08-night-1024x890.png"

  echo "$output" |
    grep "200 OK"
}

@test "http://$FQDN posts redirects" {
  run get "http://$FQDN/day-one-recap-gophercon-2016"

  echo "$output" |
    grep "Location: https://$FQDN/posts/day-one-recap-gophercon-2016"
}

@test "http://changelog.fm @ $IPv4 -> https://changelog.com/podcast" {
  run get --resolve "changelog.fm:80:$IPv4" "http://changelog.fm"

  echo "$output" |
    grep "Location: https://changelog.com/podcast\s"
}

@test "http://gotime.fm @ $IPv4 -> https://changelog.com/gotime" {
  run get --resolve "gotime.fm:80:$IPv4" "http://gotime.fm"

  echo "$output" |
    grep "Location: https://changelog.com/gotime\s"
}

@test "http://jsparty.fm @ $IPv4 -> https://changelog.com/jsparty" {
  run get --resolve "jsparty.fm:80:$IPv4" "http://jsparty.fm"

  echo "$output" |
    grep "Location: https://changelog.com/jsparty\s"
}

@test "http://rfc.fm @ $IPv4 -> https://changelog.com/rfc" {
  run get --resolve "rfc.fm:80:$IPv4" "http://rfc.fm"

  echo "$output" |
    grep "Location: https://changelog.com/rfc\s"
}

@test "http://netdata.$FQDN" {
  run get "http://netdata.$FQDN"

  echo "$output" |
    grep "netdata dashboard"

  echo "$output" |
    grep "Server: NetData Embedded HTTP Server"
}

@test "http://$FQDN/nginx_status is forbidden" {
  run get "http://$FQDN/nginx_status"

  echo "$output" |
    grep "403 Forbidden"
}
