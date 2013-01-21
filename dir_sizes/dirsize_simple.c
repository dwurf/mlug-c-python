#include "ccan/asort/asort.h" 
#include "ccan/darray/darray.h"
#include <stdio.h>

// Simple implementation of dirsize report utility - no optimisation

// Identifies the 10 largest directories on the filesystem (over 10MB)
// Operates on the output of: sudo du -Sk /

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
    //size_of_paths = [] //ccan darray
    const char BUFSIZE = 80;
    char buffer[BUFSIZE];

    int *size;
    char *path; 
    sized_path *sized_path_ptr;

    int sort_asc = 1;
    int i;

    FILE *fp;
    darray(sized_path) size_of_paths = darray_new();

    sized_path_ptr = malloc(sizeof(sized_path));
    sized_path_ptr->path = malloc(BUFSIZE);

    fp = fopen("dirsizes", "r");

    while (fgets(buffer, BUFSIZE, fp) != 0) {
        sscanf(buffer, "%d %[^\n]", &(sized_path_ptr->size), sized_path_ptr->path);
        if (sized_path_ptr->size > 10240) {
            darray_append(size_of_paths, *sized_path_ptr);
            
            // Allocate new memory for next read
            sized_path_ptr = malloc(sizeof(sized_path));
            sized_path_ptr->path = malloc(BUFSIZE);
        }
    }

    free(sized_path_ptr->path);
    free(sized_path_ptr);

    fclose(fp);

    asort(size_of_paths.item, size_of_paths.size, cmp, &sort_asc);

    i = 0;
    darray_foreach_reverse(sized_path_ptr, size_of_paths) {
        printf("%s (%d MB)\n", sized_path_ptr->path, sized_path_ptr->size / 1024);
        i++;
        if(i == 10) break;
    }

    return 0;
}
