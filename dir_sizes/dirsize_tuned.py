#!/usr/bin/env python

# Identifies the 10 largest directories on the filesystem (over 10MB)
# Operates on the output of: sudo du -Sk /

# Skips lines in the file that can easily be identified as <10MB by the number
# of digits in the file

from collections import namedtuple

def read_size_list(du_file):
    SizedPath = namedtuple('SizedPath', 'size,path')

    # A list storing (size, path) tuples
    size_of_paths = []

    # Iterate through the file
    with open(du_file) as f:
        for line in f:
            try:
                # Simple optimisation to reduce the number of splits
                # Throws IndexError exception if line is too short
                if line[4] >= '0' and line[4] <= '9':
                    # Break the line up into a number and a path
                    (size, path) = line.split(None, 1)
                    # If >10MB, add to size_of_paths list 
                    if int(size) > 10240:
                        size_of_paths.append(SizedPath(
                            int(size) / 1024,   # directory size in MB
                            path[0:-1]  # path of dir (excl. trailing newline)
                        ))
            except IndexError:
                # Line must have been < 5 characters long
                # It must have been less than 10MB, ignore
                pass

    # Sort list then print the top 10 in reverse order
    size_of_paths.sort()
    for i in range(1, 11):
        # Don't crash if there's less than 10 entries
        if len(size_of_paths) > i:
            print '%s (%d MB)' % (size_of_paths[-i].path, size_of_paths[-i].size)

if __name__ == '__main__':
    #read_size_list('dirsizes')
    import profile
    profile.run('read_size_list("dirsizes")')
