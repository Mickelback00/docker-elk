#!/usr/bin/env bash

set -e

echo -e "Starting Zipkin and the Apps"

pushd sleuth-documentation-apps
  ./scripts/start_with_zipkin_server.sh
popd
