#!/usr/bin/env bash
set -e
set -x
if [ -z "$1" ]; then
  exit 1
fi
cd "$1"
git fetch
git reset --hard origin/master
