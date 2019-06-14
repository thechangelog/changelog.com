#!/usr/bin/env bash

load http

@test "http://changelog.com @ ${IPv4:?must be set} -> https://${FQDN:?must be set}" {
  http_get --resolve "changelog.com:80:$IPv4" "http://changelog.com"
  force_https
}

@test "http://$FQDN/wp-content/uploads/balanced-150x150.jpg" {
  http_get "http://$FQDN/wp-content/uploads/balanced-150x150.jpg"
  is_ok
  is_jpg
}

@test "http://$FQDN/day-one-recap-gophercon-2016 -> https://$FQDN/posts/day-one-recap-gophercon-2016" {
  http_get "http://$FQDN/day-one-recap-gophercon-2016"

  grep "Location: https://$FQDN/posts/day-one-recap-gophercon-2016" <<< "$output"
}

@test "http://$FQDN/posts/the-new-changelog-setup-for-2019 -> https://$FQDN/posts/the-new-changelog-setup-for-2019" {
  http_get "http://${FQDN}/posts/the-new-changelog-setup-for-2019"

  grep "location: https://$FQDN/posts/the-new-changelog-setup-for-2019\s" <<< "$output"
}

@test "http://changelog.fm @ $IPv4 -> https://changelog.com/podcast" {
  http_get --resolve "changelog.fm:80:$IPv4" "http://changelog.fm"

  grep "Location: https://changelog.com/podcast\s" <<< "$output"
}

@test "http://gotime.fm @ $IPv4 -> https://changelog.com/gotime" {
  http_get --resolve "gotime.fm:80:$IPv4" "http://gotime.fm"

  grep "Location: https://changelog.com/gotime\s" <<< "$output"
}

@test "http://jsparty.fm @ $IPv4 -> https://changelog.com/jsparty" {
  http_get --resolve "jsparty.fm:80:$IPv4" "http://jsparty.fm"

  grep "Location: https://changelog.com/jsparty\s" <<< "$output"
}

@test "http://rfc.fm @ $IPv4 -> https://changelog.com/rfc" {
  http_get --resolve "rfc.fm:80:$IPv4" "http://rfc.fm"

  grep "Location: https://changelog.com/rfc\s" <<< "$output"
}

@test "http://netdata.$FQDN" {
  http_get "http://netdata.$FQDN"
  is_ok
  is_netdata
}

@test "http://$FQDN/nginx_status forbidden" {
  http_get "http://$FQDN/nginx_status"
  is_forbidden
}
