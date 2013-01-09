#!/usr/bin/env python

# Identifies the 10 largest directories on the filesystem (over 10MB)

# Operates on the output of: sudo du -Sk /

if __name__ == '__main__':
    size_of_paths = []
    with open('dirsizes') as f:
        for line in f:
            (size, path) = line.split(None, 1)
            if int(size) > 10240:
                size_of_paths.append((
                    int(size) / 1024,   # directory size in MB
                    path[0:-1]          # path to dir (excl. trailing newline)
                )) 

    size_of_paths.sort()
    for i in range(1, 10): # TODO: iterate in reverse from len(size_of_paths) to max(0, len(size_of_paths - 10))
        if len(size_of_paths) > i: # Can be removed once iteration is done in reverse
            print '%s (%d MB)' % (size_of_paths[-i][1], size_of_paths[-i][0])

