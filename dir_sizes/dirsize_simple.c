#include "ccan/asort/asort.h" 
#include "ccan/darray/darray.h"
#include <stdio.h>

// Simple implementation of dirsize report utility - no optimisation

// Identifies the 10 largest directories on the filesystem (over 10MB)
// Operates on the output of: sudo du -Sk /

#define BUFSIZE 80

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

    int *size;
    char *path; 
    sized_path sp;
    sized_path *sp_ptr;

    int sort_asc = 1;
    int i;

    FILE *fp;
    darray(sized_path) size_of_paths = darray_new();

    sp.path = malloc(BUFSIZE);

    fp = fopen("dirsizes", "r");

    while (fgets(buffer, BUFSIZE, fp) != 0) {
        // TODO: modify to handle more than BUFSIZE bytes
        sscanf(buffer, "%d %[^\n]", &(sp.size), sp.path);
        if (sp.size > 10240) {
            darray_append(size_of_paths, sp);
            
            // Allocate new memory for next read
            sp.path = malloc(BUFSIZE);
        }
    }

    free(sp.path);

    fclose(fp);

    asort(size_of_paths.item, size_of_paths.size, cmp, &sort_asc);

    i = 0;
    darray_foreach_reverse(sp_ptr, size_of_paths) {
        printf("%s (%d MB)\n", sp_ptr->path, sp_ptr->size / 1024);
        i++;
        if(i == 10) break;
    }

    darray_foreach(sp_ptr, size_of_paths)
        free(sp_ptr->path);

    darray_free(size_of_paths);

    return 0;
}
