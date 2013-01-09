#!/usr/bin/env python

# Identifies the 10 largest directories on the filesystem (over 10MB)

# Operates on the output of: sudo du -Sk /

import os

if __name__ == '__main__':
    size_of_paths = []
    with open('dirsizes') as f:
        for line in f:
            (size, path) = line.split(None, 1)
            if int(size) > 10240:
                size_of_paths.append((int(size) / 1024, path[0:-1])) 

    size_of_paths.sort()
    for i in range(1, 10):
        if len(size_of_paths) > i:
            print '%s (%d MB)' % (size_of_paths[-i][1], size_of_paths[-i][0])

# Open file and iterate across lines
# build a list of (size, path) iterables where size > 10MB
# sort, then reverse
# print top 10
