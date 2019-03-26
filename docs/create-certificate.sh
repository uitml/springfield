#!/bin/sh

set -eu
umask 077

USERNAME="$1"

CERT_DIR="${HOME}/.certs/springfield"
KEY_FILE="${CERT_DIR}/${USERNAME}.key"
CSR_FILE="${CERT_DIR}/${USERNAME}.csr"

mkdir -p "${CERT_DIR}"

if [ ! -f "${KEY_FILE}" ]; then
  openssl genrsa -out "${KEY_FILE}" 4096 >/dev/null 2>&1
  printf "Created new RSA private key\n  %s\n" $KEY_FILE
fi

openssl req \
  -new -key "${KEY_FILE}" -out "${CSR_FILE}" \
  -subj "/CN=${USERNAME}/O=user" \
  >/dev/null 2>&1
printf "Created certificate signing request...\n  %s\n" $CSR_FILE
printf "%$(tput cols)s\n" | tr ' ' '-'
cat "${CSR_FILE}" | base64 | tr -d '\n' | xargs echo
