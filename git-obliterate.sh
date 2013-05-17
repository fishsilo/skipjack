#!/usr/bin/env bash
set -e
set -x
if [ -z "$1" ]; then
  exit 1
fi
cd "$1"

if [ -n "$2" ]; then
  REMOTE_NAME="$(\
    git config --get-regexp 'remote\..*\.url' | \
    grep -F "$2" | \
    awk '{print $1}' | \
    awk -F '.' '{print $2}')"
else
  REMOTE_NAME="origin"
fi

if [ -n "$3" ]; then
  REMOTE_BRANCH_NAME="$3"
else
  REMOTE_BRANCH_NAME="master"
fi

git fetch
git reset --hard "$REMOTE_NAME/$REMOTE_BRANCH_NAME"
