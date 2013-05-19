#!/usr/bin/env bash
set -e
set -x
if [ -z "$1" ]; then
  exit 1
fi
cd "$1"

if [ -n "$2" ]; then
  REMOTE_BRANCH_NAME="$2"
else
  REMOTE_BRANCH_NAME="master"
fi

git fetch
git reset --hard "origin/$REMOTE_BRANCH_NAME"
