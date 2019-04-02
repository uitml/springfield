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

if [ ! -f "${key_file}" ] && [ ! -f "${pub_file}" ]; then
  key_comment="${username}@springfield.uit.no"
  ssh-keygen -qN "" -t rsa -f "${key_file}" -C "${key_comment}"
  printf "Created new SSH key pair\n  %s\n  %s\n" $key_file $pub_file

  fingerprint="$(ssh-keygen -lf "${key_file}" | cut -d " " -f 2)"
  if ! ssh-add -l | grep -q "${fingerprint}"; then
    sdd-add "${key_file}" >/dev/null
    printf "Added identity to authentication agent\n  %s\n" $fingerprint
  fi
else
  printf "Using existing SSH key pair\n  %s\n  %s\n" $key_file $pub_file
fi

if kubectl auth can-i create secret -qn "${username}"; then
  kubectl create secret generic ssh-keys \
    --from-file="${pub_file}" \
    --namespace="${username}" \
    --dry-run --output=yaml | kubectl apply --filename=- \
    >/dev/null
  printf "Created k8s secret containing public key\n  %s\n" ${pub_file}
else
  printf "Unable to create k8s secret...\n" >&2
  exit 1
fi
