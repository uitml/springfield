#!/bin/sh

set -eu
umask 077

username="$1"

cert_dir="${HOME}/.certs/springfield"
key_file="${cert_dir}/${username}.key"
csr_file="${cert_dir}/${username}.csr"

mkdir -p "${cert_dir}"

if [ ! -f "${key_file}" ]; then
  openssl genrsa -out "${key_file}" 4096 >/dev/null 2>&1
  printf "Created new RSA private key\n  %s\n" $key_file
fi

openssl req \
  -new -key "${key_file}" -out "${csr_file}" \
  -subj "/CN=${username}/O=user" \
  >/dev/null 2>&1
printf "Created certificate signing request...\n  %s\n" $csr_file
printf "%$(tput cols)s\n" | tr ' ' '-'
cat "${csr_file}" | base64 | tr -d '\n' | xargs echo
