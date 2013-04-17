#!/usr/bin/env python2.7

from collections import defaultdict
from itertools import chain, imap
import os
import os.path
import stat
import subprocess
import sys
import yaml

MAIN_CONFIG_FILE = "skipjack.yaml"

MODULE_CONFIG_FILE = "module.yaml"

ENFORCER_PATH = "modules/truth/manifests/enforcer.pp"


class ConfigError(ValueError):
    pass


def find_internal_modules():
    for name in os.listdir("modules"):
        if name[0] == ".":
            continue
        path = os.path.join("modules", name)
        config_file = os.path.join(path, MODULE_CONFIG_FILE)
        if os.path.isdir(path) and os.path.isfile(config_file):
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
    return os.path.basename(mod_dir)


def load_yaml(path):
    with open(path, "r") as handle:
        return yaml.safe_load(handle)


def read_roles(roles, mod_name):
    path = os.path.join("modules", mod_name, MODULE_CONFIG_FILE)
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


def goto_repo_root():
    os.chdir(subprocess.check_output(
             ["git", "rev-parse", "--show-toplevel"]).rstrip())


def find_config():
    for dirpath, dirnames, filenames in os.walk("."):
        if MAIN_CONFIG_FILE in filenames:
            return os.path.join(dirpath, MAIN_CONFIG_FILE)


def setup():
    config = load_yaml(find_config())
    module_path = config["module_path"]
    roles = defaultdict(list)
    for mod_dir in chain(*imap(find_external_modules, module_path)):
        mod_name = get_mod_name(mod_dir)
        os.symlink(os.path.abspath(mod_dir), os.path.join("modules", mod_name))
        read_roles(roles, mod_name)
    for mod_dir in find_internal_modules():
        read_roles(roles, get_mod_name(mod_dir))
    write_truth(roles)


def clean():
    if os.path.isfile(ENFORCER_PATH):
        os.unlink(ENFORCER_PATH)
    for name in os.listdir("modules"):
        path = os.path.join("modules", name)
        if os.path.islink(path):
            os.unlink(path)


def main():
    goto_repo_root()
    if len(sys.argv) == 2 and sys.argv[1] == "clean":
        clean()
    elif len(sys.argv) == 1 or sys.argv[1] == "setup":
        clean()
        setup()
    else:
        print("Usage: destiny.py [setup | clean]")
        sys.exit(1)


if __name__ == "__main__":
    main()