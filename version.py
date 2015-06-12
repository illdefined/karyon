#!/usr/bin/env python
# coding: utf-8

import re
import sys

regex = re.compile('v([0-9]+).([0-9]+).([0-9]+)-([0-9]+)-(g[0-9a-f]+)(-dirty)?')
match = regex.match(sys.stdin.readlines()[0])

major = int(match.group(1))
minor = int(match.group(2))
micro = int(match.group(3))

pre = int(match.group(4))
scm = match.group(5)
dirty = match.group(6)

# Pre‐release?
if pre > 0 or dirty:
    micro += 1
    version = '{}.{}.{}-{}'.format(major, minor, micro, pre)

    # Dirty working tree?
    if dirty:
        version += '-dirty'
else:
    version = '{}.{}.{}'.format(major, minor, micro)

# Build metadata
version += '+{}'.format(scm)

print('VERSION := {}\nMAJOR := {}\nMINOR := {}\nMICRO := {}'.format(version, major, minor, micro))
