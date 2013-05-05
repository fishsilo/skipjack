#!/usr/bin/env python2.7
"""Skipjack

Usage:
    skipjack bootstrap --config=<file> (--hosts=<hosts>|--vagrant)
    skipjack provision (--hosts=<hosts>|--vagrant)
"""

import os
import subprocess
import sys

from docopt import docopt


def init_fab_args(opts):
    if opts["--vagrant"]:
        return ["./fab-vagrant"]
    else:
        return ["fab", "-H", opts["--hosts"]]


def bootstrap_task(opts):
    if "--config" in opts:
        return "bootstrap:config=%s" % opts["--config"]
    else:
        return "bootstrap"


def main(opts):
    fab_args = init_fab_args(opts)
    if opts["bootstrap"]:
        fab_args.append(bootstrap_task(opts))
    elif opts["provision"]:
        fab_args.append("provision")
    subprocess.check_call(fab_args, close_fds=True)

if __name__ == "__main__":
    main(docopt(__doc__))
