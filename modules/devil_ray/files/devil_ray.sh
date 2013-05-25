#!/usr/bin/env bash
set -e

cd /opt/devil_ray

if [ ! -d ENV ]; then
  virtualenv ENV
fi

source ENV/bin/activate

pip install -r requirements.txt

exec ./devil_ray.py
