#!/usr/bin/env bash

load http

@test "http://${FQDN:?must be set}" {
  get "http://$FQDN" |
    grep "Changelog Media LLC"
}

@test "http://${IPv4:?must be set}" {
  get "http://$IPv4" |
    grep "Changelog Media LLC"
}
