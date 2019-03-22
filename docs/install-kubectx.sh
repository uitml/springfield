#!/bin/sh

set -eu

API_URL="https://api.github.com/repos/ahmetb/kubectx/releases/latest"

mkdir -p /tmp/kubectx && cd /tmp/kubectx
curl -s "${API_URL}" \
  | grep "tarball_url" \
  | cut -d '"' -f 4 \
  | xargs curl -Lo kubectx.tar.gz
tar -xf kubectx.tar.gz --strip-components=1
chmod +x kubectx kubens
sudo cp --no-preserve=ownership kubectx kubens /usr/local/bin/
