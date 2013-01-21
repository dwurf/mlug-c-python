sort -nr dirsizes | head | sed 's/\([0-9]*\)\s*\(.*\)/\2 (\1 MB)/'
