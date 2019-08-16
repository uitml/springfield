#!/usr/bin/env bash

set -eu

# https://stackoverflow.com/a/17841619/57858
function join_by { local IFS="$1"; shift; echo "$*"; }

# Assumptions:
#   1. sshfs is available.
#   2. /etc/fuse.conf has `user_allow_other`.
#   3. kubectl context is set to user's namespace.

uid=$(id -u)
gid=$(id -g)

# Assume current context is set to Springfield.
context="$(kubectl config current-context)"

# Find namespace via our naming convention; username@springfield
namespace="${context%%@springfield}"
echo "Using namespace '${namespace}'..."

fs="root@springfield.uit.no:/root"
key="${HOME}/.ssh/${namespace}"
dir="${HOME}/Springfield"

# Find 'storage-proxy' SSH port.
port="$(kubectl get svc -o jsonpath="{.items[?(@.metadata.name=='storage-proxy')]..nodePort}")"
echo "Targeting SSH server on port ${port}"

# Define mount options.
opts=(
  "_netdev"
  "noauto"
  "x-systemd.automount"
  "reconnect"
  "allow_other"
  "user"
  "follow_symlinks"
  "idmap=user"
  "identityfile=${key}"
  "uid=${uid}"
  "gid=${gid}"
  "port=${port}"
)

# TODO: Locate this based on (common) system defaults?
fstab="/etc/fstab"

# Create /etc/fstab entry.
# <file system>  <mount point>  <type>  <options>  <dump>  <pass>
entry="${fs}  ${dir}  fuse.sshfs $(join_by , "${opts[@]}")  0  0"
echo "${entry}" | sudo tee -a "${fstab}" >> /dev/null

# TODO: Restart affected services (on common systems) automatically?
# ...
