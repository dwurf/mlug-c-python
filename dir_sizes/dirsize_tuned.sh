grep -E '^[0-9]{5,}' dirsizes | sort -nr | head | sed 's/\([0-9]*\)\s*\(.*\)/\2 (\1 MB)/'
