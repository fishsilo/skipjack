#!/usr/bin/env bash
set -e

KEY_FILE="secret_key"
SECRETS_DIR="repos"

if [ ! -f "$KEY_FILE" ]; then
  echo "No $KEY_FILE; skipping decryption step."
  exit 0
fi

if [ ! -d "$SECRETS_DIR" ]; then
  echo "No $SECRETS_DIR; skipping decryption step."
  exit 0
fi

for i in $(find repos -name '*.bfe'); do
  cat secret_key | bcrypt "$i" 2>/dev/nul
done

