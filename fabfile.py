#!/usr/bin/env python2.7

import os.path
from fabric.api import *

env.user = 'root'

fab_dir = os.path.dirname(env.real_fabfile)

def bootstrap():
    run('apt-get install -q -y ruby git')
    run('gem install --no-ri --no-rdoc puppet')
    run('git clone git://github.com/fishsilo/skipjack.git')
    provision()

def provision():
    with cd('skipjack'):
        run('git fetch')
        run('git reset --hard origin/master')
        run('./run.sh')
