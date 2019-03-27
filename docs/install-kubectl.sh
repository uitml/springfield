#!/bin/sh

set -eu

api_url="https://storage.googleapis.com/kubernetes-release/release"
version="$(curl -s ${api_url}/stable.txt)"
platform="$(uname -s | tr "[:upper:]" "[:lower:]")"

mkdir -p /tmp/kubectl && cd /tmp/kubectl
curl -LO "${api_url}/${version}/bin/${platform}/amd64/kubectl"
chmod +x kubectl
sudo cp --no-preserve=ownership kubectl /usr/local/bin/
