#!/usr/bin/env bash

FQDN="${FQDN:-changelog.localhost}"
IPv4="${IPv4:-127.0.0.1}"

load http

@test "http://${FQDN:?must be set}" {
  http_get "http://$FQDN"
  is_ok
  is_changelog
}

@test "http://${IPv4:?must be set}" {
  http_get "http://$IPv4"
  is_ok
  is_changelog
}

@test "http://changelog.com @ $IPv4 X-Forwarded-Proto https" {
  http_get --header "X-Forwarded-Proto: https" --resolve "changelog.com:80:$IPv4" "http://changelog.com"
  is_ok
  is_changelog
}
