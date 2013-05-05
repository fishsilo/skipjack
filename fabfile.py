#!/usr/bin/env python2.7

import os.path
import tempfile
import yaml
from fabric.api import *

env.user = 'root'

fab_dir = os.path.dirname(env.real_fabfile)

LOCAL_CONFIG_FILE = "bootstrap.yaml"
ROOT = "skipjack"
CONFIG_FILE = "provision.yaml"
CONFIG_REPO = "provision.yaml.d"
KEY_FILE = "secrets.key"
SECRET_REPO = "secrets.d"
SECRET_TARBALL = SECRET_REPO + ".tar.gz"


def load_yaml(path):
    with open(path, "r") as handle:
        return yaml.safe_load(handle)


def _get_config(config=None):
    config_file = config.get("file", CONFIG_FILE)
    config_repo = config.get("repo")
    if config_repo:
        run('git clone %s %s' % (config_repo, CONFIG_REPO))
        run('cp %s/%s %s' % (CONFIG_REPO, config_file, CONFIG_FILE))
    else:
        put(local_path=config_file, remote_path=CONFIG_FILE)


def _get_secrets(config=None):
    key_file = config.get("key_file")
    secret_dir = config.get("dir")
    secret_repo = config.get("repo")
    if not key_file:
        return
    if not (secret_dir or secret_repo):
        return
    if secret_dir and secret_repo:
        return
    if secret_repo:
        run('git clone %s %s' % (secret_repo, SECRET_REPO))
    else:
        (fd, temp) = tempfile.mkstemp(prefix=SECRET_REPO, suffix=".tar.gz")
        os.close(fd)
        local('cd %s && tar -czf %s *' % (secret_dir, temp))
        put(local_path=temp, remote_path=SECRET_TARBALL)
        run('mkdir -p %s' % SECRET_REPO)
        with cd(SECRET_REPO):
            run('tar -xzf ../%s' % SECRET_TARBALL)
    put(local_path=key_file, remote_path=KEY_FILE)
    # run("""for i in $(find %s -name '*.bfe'); do cat %s | bcrypt "$i"; done""" %
    #    (SECRET_REPO, KEY_FILE))


def bootstrap(config=LOCAL_CONFIG_FILE):
    run('mkdir -p %s' % ROOT)
    with cd(ROOT):
        config = load_yaml(config)
        run('apt-get install -q -y ruby git python-pip bcrypt')
        _get_config(config["provision"])
        _get_secrets(config["secrets"])
        run('pip -q install virtualenv')
        run('gem install --no-ri --no-rdoc puppet')
        run('git clone git://github.com/fishsilo/skipjack.git')
        with cd('skipjack'):
            run('virtualenv ENV')
    provision()


def provision():
    with cd(ROOT):
        with cd('skipjack'):
            run('git fetch')
            run('git reset --hard origin/master')
            # TODO fetch in all other repos originally cloned by
            # skipjack/destiny
            run('./run.sh')


def echo(message="Hello, world!"):
    run("""echo '%s'""" % message)
