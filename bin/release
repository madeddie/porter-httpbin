#!/bin/bash

set -e
if [[ -n "$CI" ]]; then set -x; fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$(dirname $DIR)"

version=$(sed -e 's/+/./' httpbin/VERSION)

image=$(awk -F= '/org.opencontainers.image.name/ { print $2 }' < Dockerfile)
image="${image}:${version}"
if [[ "$(uname -m)" = "arm64" ]]; then
    opts="--platform linux/amd64"
fi
docker build --target production $opts --tag $image .
docker push $image
