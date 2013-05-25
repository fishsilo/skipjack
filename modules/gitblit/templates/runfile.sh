#!/usr/bin/env bash
set -e

sleep 1

GITBLIT_PATH="<%= root %>"
GITBLIT_BASE_FOLDER="<%= data %>"
GITBLIT_USER="<%= user %>"

. /lib/lsb/init-functions

cd "$GITBLIT_PATH"
exec sudo -u "$GITBLIT_USER" -- \
  java -server -Xmx1024M -Djava.awt.headless=true \
  -jar "$GITBLIT_PATH/gitblit.jar" \
  --baseFolder "$GITBLIT_BASE_FOLDER"
