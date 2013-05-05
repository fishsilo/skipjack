#!/usr/bin/env python2.7
"""Skipjack

Usage:
    skipjack bootstrap [options] (--hosts=<hosts>|--vagrant)
    skipjack provision (--hosts=<hosts>|--vagrant)

Options:
    --config-file=<file>    Path to config file (local unless --config-repo is given)
    --config-repo=<repo>    URL of repo with config file
    --key-file=<file>       Local path to key file
    --secret-dir=<dir>      Local directory with files encrypted by the key
    --secret-repo=<repo>    URL of repo with files encrypted by the key
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

def task_opt(i_opts, i_name, o_opts, o_name):
  if i_opts[i_name]:
    o_opts.append("%s=%s" % (o_name, i_opts[i_name]))

def bootstrap_task(opts):
  task_opts = []
  task_opt(opts, "--config-file", task_opts, "config_file")
  task_opt(opts, "--config-repo", task_opts, "config_repo")
  task_opt(opts, "--key-file", task_opts, "key_file")
  task_opt(opts, "--secret-dir", task_opts, "secret_dir")
  task_opt(opts, "--secret-repo", task_opts, "secret_repo")
  return "bootstrap:%s" % ",".join(task_opts)

def main(opts):
  fab_args = init_fab_args(opts)
  if opts["bootstrap"]:
      fab_args.append(bootstrap_task(opts))
  elif opts["provision"]:
      fab_args.append("provision")
  subprocess.check_call(fab_args, close_fds=True)

if __name__ == "__main__":
    main(docopt(__doc__))
