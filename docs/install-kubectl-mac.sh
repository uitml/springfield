#!/bin/sh

set -eu
umask 077

api_url="https://storage.googleapis.com/kubernetes-release/release"
version="$(curl -s ${api_url}/stable.txt)"
platform="$(uname -s | tr "[:upper:]" "[:lower:]")"

mkdir -p /tmp/kubectl && cd /tmp/kubectl
curl -LO "${api_url}/${version}/bin/${platform}/arm64/kubectl"
chmod +x kubectl
sudo mkdir -p /usr/local/bin
sudo mv kubectl /usr/local/bin/
