#!/usr/bin/env python2.7

import os.path
import tempfile
import shutil
from subprocess import check_output, Popen
from fabric.api import *

env.user = 'root'

fab_dir = os.path.dirname(env.real_fabfile)


CLONE_ADDRESS = "127.0.0.1"
CLONE_PORT = 8149
CLONE_DIR = "skipjack-config.git"


KEY = None


def get_key(path):
    global KEY
    if path == "":
        KEY = prompt("Decryption key?").strip()
    else:
        with open(path, "r") as key_file:
            KEY = key_file.read().strip()


def put_key():
    with shell_env(KEY=KEY):
        run("""cat - <<<"$KEY" >secret_key""")
        run("chmod 600 secret_key")


def clone_local_config(repo):
    git_daemon = Popen([
        "git", "daemon",
        "--strict-paths", "--export-all", "--base-path=" + repo,
        "--listen=127.0.0.1", "--port=" + CLONE_PORT, repo])
    try:
        with remote_tunnel(CLONE_PORT, remote_bind_address=CLONE_ADDRESS):
            run("git clone git://%s:%s/ %s" %
                    (CLONE_ADDRESS, CLONE_PORT, CLONE_DIR))
            return CLONE_DIR
    finally:
        git_daemon.terminate()


def pick_source():
    return check_output(["./pick-source.sh"])


def bootstrap(repo, key_file):
    get_key(key_file)
    if repo.startswith("/"):
        repo = clone_local_config(repo)
    run('apt-get install -q -y ruby git python-pip bcrypt')
    run('pip -q install virtualenv')
    run('gem install --no-ri --no-rdoc puppet')
    branch = pick_source()
    run("git clone -b '%s' git://github.com/fishsilo/skipjack.git" % branch)
    with cd('skipjack'):
        put_key()
        run('virtualenv ENV')
        run('git clone %s config' % repo)
    provision(fresh=True)


def provision(fresh=False):
    with cd('skipjack'):
        if not fresh:
            run("./git-obliterate.sh . '%s'" % pick_source())
        run('./run.sh')


