#!/usr/bin/env bash

load http

@test "http://${FQDN:?must be set} -> https://$FQDN" {
  http_get "http://$FQDN"
  force_https
}

@test "https://$FQDN" {
  http_get "https://$FQDN"
  is_ok
  is_changelog
}

@test "http://changelog.com @ ${IPv4:?must be set} X-Forwarded-Proto https -> https://changelog.com/ - NodeBalancer overwrite" {
  http_get --header "X-Forwarded-Proto: https" --resolve "changelog.com:80:$IPv4" "http://changelog.com"
  force_https
}


@test "http://${IPv4:?must be set} -> https://$FQDN" {
  http_get "http://$IPv4"
  force_https
}

@test "https://$IPv4" {
  http_get "https://$IPv4" --insecure
  is_ok
  is_changelog
}

@test "https://$FQDN/wp-content/uploads/balanced-150x150.jpg" {
  http_get "https://$FQDN/wp-content/uploads/balanced-150x150.jpg"
  is_ok
  is_jpg
}

@test "https://netdata.$FQDN" {
  http_get "http://netdata.$FQDN"
  is_ok
  is_netdata
}
