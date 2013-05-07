#!/usr/bin/env python2.7
"""Skipjack

Usage:
    skipjack bootstrap (--hosts=<hosts>|--vagrant) [--key=<file>] [<repo>]
    skipjack provision (--hosts=<hosts>|--vagrant)
"""

import os
import subprocess

from docopt import docopt


def init_fab_args(opts):
    if opts["--vagrant"]:
        return ["./fab-vagrant"]
    else:
        return ["fab", "-H", opts["--hosts"]]


def bootstrap_task(opts):
    repo = opts["<repo>"] or ""
    key_file = opts["--key"] or ""
    return "bootstrap:%s,%s" % (repo, key_file)


def main(opts):
    print(opts)
    fab_args = init_fab_args(opts)
    if opts["bootstrap"]:
        fab_args.append(bootstrap_task(opts))
    elif opts["provision"]:
        fab_args.append("provision")
    subprocess.check_call(fab_args, close_fds=True)

if __name__ == "__main__":
    main(docopt(__doc__))
