// Implementation of dirsize report utility

// Identifies the 10 largest directories on the filesystem (over 10MB)
// Operates on the output of: sudo du -Sk /

// This version eliminates slow system calls for memory allocations by 
// allocating memory from a static block allocated at program startup

// It is a work in progress, string handling and memory management are very
// broken.

#include <stdio.h>
#include <string.h>

// Uses the Comprehensive C Archive Network implementations of sort and
// dynamic arrays
#include "ccan/asort/asort.h" 
#include "ccan/darray/darray.h"
#include "ccan/antithread/alloc/alloc.h"

#define BUFSIZE 80
// Very large block. OS will allocate memory as required so no problem.
#define MEMSIZE 1024*1024*128 

typedef struct {
    int size;
    char *path;
} sized_path;

static int cmp(const sized_path *a, const sized_path *b, const int *asc)
{
    return asc ? (a->size > b->size) - (a->size < b->size) : (a->size < b->size) - (a->size > b->size);
}

int main() 
{
    char buffer[BUFSIZE];
    static char memblock[MEMSIZE];

    int *size;
    char *path; 
    sized_path sp;
    sized_path *sp_ptr;

    int sort_asc = 1;
    int i;

    FILE *fp;
    darray(sized_path) size_of_paths = darray_new();

    alloc_init(memblock, MEMSIZE);

    sp.path = alloc_get(memblock, MEMSIZE, BUFSIZE, 0);

    fp = fopen("dirsizes", "r");

    while (fgets(buffer, BUFSIZE, fp) != 0) {
        if(strlen(buffer) >= 5 && buffer[4] >= '0' && buffer[4] <= '9') {
            // TODO: modify to handle more than BUFSIZE bytes
            sscanf(buffer, "%d %[^\n]", &(sp.size), sp.path);
            if (sp.size > 10240) {
                darray_append(size_of_paths, sp);
                // Allocate new memory for next read
                sp.path = alloc_get(memblock, MEMSIZE, BUFSIZE, 0);
            }
        }
    }

    alloc_free(memblock, MEMSIZE, sp.path);

    fclose(fp);

    asort(size_of_paths.item, size_of_paths.size, cmp, &sort_asc);

    i = 0;
    darray_foreach_reverse(sp_ptr, size_of_paths) {
        printf("%s (%d MB)\n", sp_ptr->path, sp_ptr->size / 1024);
        i++;
        if(i == 10) break;
    }

    darray_foreach(sp_ptr, size_of_paths)
        alloc_free(memblock, MEMSIZE, sp_ptr->path);

    darray_free(size_of_paths);

    return 0;
}

