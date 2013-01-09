#!/usr/bin/env python

# Identifies the 10 largest directories on the filesystem (over 10MB)

# Operates on the output of: sudo du -Sk /

import mmap

if __name__ == '__main__':
    size_of_paths = []
    with open('dirsizes') as f:
        m = mmap.mmap(f.fileno(), 0, prot=mmap.PROT_READ)
        start = None
        size = None
        for c in m:
            if start == None:
                start = f.tell()
                continue
            elif c != '\t':
                continue
            else:
                read = m.tell() - start
                m.seek(start)
                size = int(m.read(read))
                m.read_byte()
                size_of_paths.append((size / 1024, m.readline()[0:-1]))
                start = None
                size = None
                print size
                


    size_of_paths.sort()
    for i in range(1, 10): # TODO: iterate in reverse from len(size_of_paths) to max(0, len(size_of_paths - 10))
        if len(size_of_paths) > i: # Can be removed once iteration is done in reverse
            print '%s (%d MB)' % (size_of_paths[-i][1], size_of_paths[-i][0])

