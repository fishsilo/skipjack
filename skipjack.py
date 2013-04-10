#!/usr/bin/env python2.7
"""Skipjack

Usage:
    skipjack config [options]
    skipjack list
    skipjack init <host>
    skipjack run <host>

Options:
    --api-key <key>     Linode API key
"""

import os
import shelve
import sys
from pprint import pprint

from docopt import docopt
from linode import api as linode_api

args = None

SHELF_PATH = os.path.join(os.environ.get("HOME"), ".skipjack")

l_api = api.Api(API_KEY)
linodes = l_api.linode_list()

for linode in linodes:
    ips = l_api.linode_ip_list(LinodeID=linode['LINODEID'])
    pprint(ips)


def linode_list(api):
    return api.linode_list()


def console():
    global args
    args = docopt(__doc__)

    shelf = shelve.open(SHELF_PATH)

    linode_api_key = shelf.get('LINODE_API_KEY')
    if not linode_api_key:
        pass


    api = linde_api.Api(

if __name__ == "__main__":
    console()
