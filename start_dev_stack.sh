#!/bin/sh

BASE_DIR=$(cd "$(dirname "$0")"; pwd)/dev_docker

cd $BASE_DIR

docker-compose \
  -f "./changelog.yml" \
  -f "./prometheus.yml" \
  -f "./postgres.yml" \
  -f "./grafana.yml" \
  "$@"
