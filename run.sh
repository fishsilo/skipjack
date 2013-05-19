#!/usr/bin/env bash

set -e

source ENV/bin/activate
pip -q install -r requirements.prod.txt
if [ -d config ]; then
  ./git-obliterate.sh config
fi
./decrypt.sh

SKIPJACK="$PWD"
cd config
puppet apply $* \
  --modulepath "modules:$SKIPJACK/modules" \
  --confdir . \
  "$SKIPJACK/manifests/site.pp"
