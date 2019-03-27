#!/bin/sh

set -eu
umask 077

read -p "Username (xyz012): " username </dev/tty

# Validate the username to ensure it follows the "xyz012" format.
if ! echo "${username}" | egrep -q "^[a-z]{3}[0-9]{3}$"; then
  printf "Invalid username...\n" >&2
  exit 1
fi

ssh_root="${HOME}/.ssh"
key_file="${ssh_root}/$username"
pub_file="${key_file}.pub"

mkdir -p "${ssh_root}"

if [ ! -f "${key_file}" ]; then
  ssh-keygen -q -t rsa -f "${key_file}" -C "${username}@uit.no"
  printf "Created new SSH key\n  %s\n" $key_file
fi

kubectl create secret generic ssh-keys \
  --from-file="${pub_file}" \
  --namespace="${username}" \
  --dry-run --output=yaml | kubectl apply --filename=- \
  >/dev/null 2>&1
printf "Created k8s secret containing public key\n  %s\n" ${pub_file}
