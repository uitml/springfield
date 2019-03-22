#!/bin/sh

set -eu

API_URL="https://storage.googleapis.com/kubernetes-release/release"
VERSION="$(curl -s ${API_URL}/stable.txt)"
PLATFORM="$(uname -s | tr "[:upper:]" "[:lower:]")"

mkdir -p /tmp/kubectl && cd /tmp/kubectl
curl -LO "${API_URL}/${VERSION}/bin/${PLATFORM}/amd64/kubectl"
chmod +x kubectl
sudo cp --no-preserve=ownership kubectl /usr/local/bin/
