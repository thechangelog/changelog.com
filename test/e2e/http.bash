#!/usr/bin/env bash

http_get() {
  run curl --verbose --silent "${@}"
  # $output is special to run: https://github.com/bats-core/bats-core#run-test-other-commands
  # shellcheck disable=SC2154
  echo "output: $output"
}

is_ok() {
  grep "200 OK" <<< "$output"
}

is_forbidden() {
  grep "403 Forbidden" <<< "$output"
}

is_changelog() {
  grep "Changelog Media LLC" <<< "$output"
}

force_https() {
  grep "location: https://$FQDN/\s" <<< "$output"
}

is_netdata() {
  grep "netdata dashboard" <<< "$output"
  grep "Server: NetData Embedded HTTP Server" <<< "$output"
}

is_jpg() {
  grep "Content-Type: image/jpeg" <<< "$output"
}
