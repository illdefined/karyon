#!/usr/bin/env python2
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
    build = '{}.{}.{}-{}'.format(major, minor, micro, pre)

    # Dirty working tree?
    if dirty:
        build += '-dirty'
else:
    build = '{}.{}.{}'.format(major, minor, micro)

# Build metadata
build += '+{}'.format(scm)

print 'BUILD := {}\nMAJOR := {}\nMINOR := {}\nMICRO := {}\nSCM := {}'.format(build, major, minor, micro, scm)

if pre > 0 or dirty:
    print 'PRE := {}'.format(pre)

    if dirty:
        print 'DIRTY := 1'
