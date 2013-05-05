#!/usr/bin/env bash
set -e

KEY_FILE="$1"
SECRETS_DIR="$2"

SKIP_HEAD=$(( ${#SECRETS_DIR} + 1 ))
SKIP_TAIL=4

function var_name {
  SUB_LEN=$(( ${#1} - $SKIP_HEAD - $SKIP_TAIL ))
  echo "${1:$SKIP_HEAD:$SUB_LEN}" | tr ./ __
}

TMPL="export FACTER_secret_%s='%s'"

for i in $(find "$SECRETS_DIR" -name '*.bfe'); do
  printf "$TMPL" "$(var_name "$i")" "$(cat "$KEY_FILE" | bcrypt -o "$i" 2>/dev/null)"
done

