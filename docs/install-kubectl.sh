#!/bin/sh

set -eu
umask 077

api_url="https://storage.googleapis.com/kubernetes-release/release"
version="$(curl -s ${api_url}/stable.txt)"
platform="$(uname -s | tr "[:upper:]" "[:lower:]")"
arch="$(uname -m)"
if [ "$arch" = "x86_64" ]; then
  arch="amd64"
elif [ "$arch" = "arm64" ] || [ "$arch" = "aarch64" ]; then
  arch="arm64"
else
  echo "Unsupported architecture: $arch"
  exit 1
fi

mkdir -p /tmp/kubectl && cd /tmp/kubectl
curl -LO "${api_url}/${version}/bin/${platform}/${arch}/kubectl"
chmod +x kubectl
sudo mkdir -p /usr/local/bin
sudo mv kubectl /usr/local/bin/
