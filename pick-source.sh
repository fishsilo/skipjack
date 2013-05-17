#!/usr/bin/env bash
set -e

BRANCH_PREFIX="refs/heads/"

function get_branch_name {
  FULL_NAME="$1"
  if [ "${FULL_NAME:0:${#BRANCH_PREFIX}}" = "$BRANCH_PREFIX" ]; then
    echo "${FULL_NAME:${#BRANCH_PREFIX}}"
  else
    echo "Not a normal branch: $FULL_NAME!" 1>&2
    exit 1
  fi
}

HEAD_NAME="$(git rev-parse --symbolic-full-name HEAD)"
BRANCH_NAME="$(get_branch_name "$HEAD_NAME")"

REMOTE_NAME="$(git config --get "branch.$BRANCH_NAME.remote" || echo .)"
if [ "$REMOTE_NAME" = "." ]; then
  echo "Branch $BRANCH_NAME doesn't have a real remote!" 1>&2
  exit 1
fi

REMOTE_MERGE="$(git config --get "branch.$BRANCH_NAME.merge" || true)"
if [ -z "$REMOTE_MERGE" ]; then
  echo "Branch $BRANCH_NAME doesn't have a remote merge spec!" 1>&2
  exit 1
fi

REMOTE_BRANCH_NAME="$(get_branch_name "$REMOTE_MERGE")"

HEAD_COMMIT="$(git rev-parse HEAD)"
REMOTE_FULL_NAME="refs/remotes/$REMOTE_NAME/$REMOTE_BRANCH_NAME"
if git rev-list "$REMOTE_FULL_NAME" | grep -qF "$HEAD_COMMIT"; then
  echo "Remote is up-to-date." 1>&2
else
  read -p "Remote is out-of-date. Push? [y] " SHOULD_PUSH
  if grep -qi '^y' <<<"$SHOULD_PUSH"; then
    git push "$REMOTE_NAME" "$HEAD_NAME:$REMOTE_MERGE"
  else
    echo "Not pushing." 1>&2
  fi
fi

echo -n "$REMOTE_BRANCH_NAME"
