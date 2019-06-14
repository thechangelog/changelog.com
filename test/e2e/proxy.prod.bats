#!/usr/bin/env bash

load http

@test "http://${FQDN:?must be set}" {
  get "http://$FQDN" |
    grep "location: https://$FQDN"
}

@test "https://$FQDN" {
  get "https://$FQDN" |
    grep "Changelog Media LLC"
}

@test "http://${IPv4:?must be set}" {
  get "http://$IPv4" |
    grep "location: https://$FQDN"
}

@test "https://$IPv4" {
  get "https://$IPv4" --insecure |
    grep "Changelog Media LLC"
}

@test "https://$FQDN legacy assets" {
  run get "https://$FQDN/wp-content/uploads/changelog-nightly-2015-03-08-night-1024x890.png"

  echo "$output" |
    grep "200 OK"
}

@test "https://netdata.$FQDN" {
  run get "http://netdata.$FQDN"

  echo "$output" |
    grep "netdata dashboard"

  echo "$output" |
    grep "Server: NetData Embedded HTTP Server"
}
