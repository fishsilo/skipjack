#!/usr/bin/env python2.7

from collections import defaultdict
import hashlib
import os
from os.path import abspath, basename, isdir, isfile, join
import subprocess
import yaml

MAIN_CONFIG_FILE = "skipjack.yaml"

MODULE_CONFIG_FILE = "module.yaml"

EXTERNAL_REPO_ROOT = "repos"

ENFORCER_PATH = "modules/truth/manifests/enforcer.pp"


class ConfigError(ValueError):
    pass


def find_internal_modules():
    for name in os.listdir("modules"):
        if name[0] == ".":
            continue
        path = join("modules", name)
        config_file = join(path, MODULE_CONFIG_FILE)
        if isdir(path) and isfile(config_file):
            yield path


def find_external_modules(root):
    for dirpath, dirnames, filenames in os.walk(root):
        # Remove hidden directories
        for dirname in dirnames:
            if dirname[0] == ".":
                dirnames.remove(dirname)
        # See if we are in a module directory
        if MODULE_CONFIG_FILE in filenames:
            yield dirpath
            dirnames[:] = []


def get_mod_name(mod_dir):
    return basename(mod_dir)


def load_yaml(path):
    with open(path, "r") as handle:
        return yaml.safe_load(handle)


def read_roles(roles, mod_name):
    path = join("modules", mod_name, MODULE_CONFIG_FILE)
    doc = load_yaml(path)
    doc_roles = doc and doc["roles"]
    if doc_roles:
        if type(doc_roles) is not list:
            raise ConfigError("'roles' must be a list")
        for role in doc_roles:
            if type(role) is not str:
                raise ConfigError("each role must be a string")
            if role in roles:
                roles[role].append(mod_name)
            else:
                roles[role] = [mod_name]


def write_truth(roles):
    with open(ENFORCER_PATH, "w") as out:
        out.write("""
      class truth::enforcer {
        require truth::universal
    """)
        for role in roles:
            out.write("if has_role(\"%s\") {\n" % (role,))
            for mod in roles[role]:
                out.write("include %s\n" % (mod,))
            out.write("notice(\"I am a %s\")\n}\n" % (role,))
        out.write("}\n")


def clone_repo(url):
    path = join(EXTERNAL_REPO_ROOT, hashlib.sha1(url).hexdigest())
    if isdir(path):
        subprocess.check_call(["./git-obliterate.sh", path], close_fds=True)
    else:
        subprocess.check_call(["git", "clone", url, path], close_fds=True)


def find_config():
    for dirpath, dirnames, filenames in os.walk("."):
        if MAIN_CONFIG_FILE in filenames:
            return join(dirpath, MAIN_CONFIG_FILE)
    return None


def main():
    config_file = find_config()
    if config_file:
        config = load_yaml(config_file) or {}
        for url in config.get("repos", []):
            clone_repo(url)
    roles = defaultdict(list)
    for mod_dir in find_external_modules(EXTERNAL_REPO_ROOT):
        mod_name = get_mod_name(mod_dir)
        os.symlink(abspath(mod_dir), join("modules", mod_name))
        read_roles(roles, mod_name)
    for mod_dir in find_internal_modules():
        read_roles(roles, get_mod_name(mod_dir))
    write_truth(roles)


if __name__ == "__main__":
    main()
