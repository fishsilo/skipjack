#!/usr/bin/env python2.7

import os.path
from fabric.api import *

env.user = 'root'

fab_dir = os.path.dirname(env.real_fabfile)

def bootstrap():
    run('apt-get install -q -y ruby1.9.1 git')
    run('gem install --no-ri --no-rdoc puppet')
    run('git clone git://github.com/fishsilo/puppet.git')
    provision()

def provision():
    with cd('puppet'):
        run('./run.sh')
