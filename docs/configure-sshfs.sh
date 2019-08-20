#!/usr/bin/env bash

set -eu

# https://stackoverflow.com/a/17841619/57858
function join_by { local IFS="$1"; shift; echo "$*"; }

# Assumptions:
#   1. sshfs is available.
#   2. /etc/fuse.conf is configured with `user_allow_other`.
#   3. kubectl context is set to user's namespace.

uid=$(id -u)
gid=$(id -g)

# Assume current context is set to Springfield.
context="$(kubectl config current-context)"

# Find namespace via our naming convention; username@springfield.
namespace="${context%%@springfield}"

# Validate the namespace to ensure it follows the "xyz012" format.
if ! echo "${namespace}" | egrep -q "^[a-z]{3}[0-9]{3}$"; then
  printf "Incorrect user in current kubectl context: %s\n" $namespace >&2
  exit 1
fi

printf "Using namespace %s...\n" $namespace

fs="root@springfield.uit.no:/root"
key="${HOME}/.ssh/${namespace}"
dir="${HOME}/Springfield"

# Find 'storage-proxy' SSH port.
port="$(kubectl get svc -o jsonpath="{.items[?(@.metadata.name=='storage-proxy')]..nodePort}")"

# Check that we found a service port.
if [[ -z "${port// }" ]]; then
  printf "Unable to find a storage proxy port\n"
  exit 1
fi

printf "Targeting SSH server on port %s\n" $port

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

# Check if fstab already contains a Springfield entry?
if match="$(grep -F "@springfield.uit.no" "${fstab}")"; then
  printf "Found existing entry in %s\n" $fstab
  exit 1
fi

# Create /etc/fstab entry.
# <file system>  <mount point>  <type>  <options>  <dump>  <pass>
entry="${fs}  ${dir}  fuse.sshfs $(join_by , "${opts[@]}")  0  0"
echo "${entry}" | sudo tee -a "${fstab}" >> /dev/null

printf "\nAdded the following to %s:\n  %s\n" $fstab $entry

# TODO: Restart affected services (on common systems) automatically?
