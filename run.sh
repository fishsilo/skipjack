#!/usr/bin/env bash

set -e

if [ -z "$FACTER_server_tags" ]; then
    FACTER_server_tags="nil"
fi

export FACTER_server_tags

source ENV/bin/activate
pip -q install -r requirements.txt
./destiny.py setup
puppet apply $* --modulepath ./modules manifests/site.pp
