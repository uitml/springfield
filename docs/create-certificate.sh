#!/bin/sh

set -eu

USERNAME="$1"

CERT_DIR="${HOME}/.certs/springfield"
KEY_FILE="${CERT_DIR}/${USERNAME}.key"
CSR_FILE="${CERT_DIR}/${USERNAME}.csr"

mkdir -p "${CERT_DIR}" && chmod 700 "${CERT_DIR}"

openssl req \
  -newkey rsa:4096 -keyout "${KEY_FILE}" -nodes \
  -new -out "${CSR_FILE}" \
  -subj "/CN=${USERNAME}/O=user" \
  >/dev/null 2>&1

cat "${CSR_FILE}" | base64
