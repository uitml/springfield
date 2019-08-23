#!/bin/sh

set -eu
umask 077

api_url="https://api.github.com/repos/ahmetb/kubectx/releases/latest"

mkdir -p /tmp/kubectx && cd /tmp/kubectx
curl -s "${api_url}" \
  | grep "tarball_url" \
  | cut -d '"' -f 4 \
  | xargs curl -Lo kubectx.tar.gz
tar -xf kubectx.tar.gz --strip-components=1
chmod +x kubectx kubens
sudo mkdir -p /usr/local/bin
sudo mv kubectx kubens /usr/local/bin/
