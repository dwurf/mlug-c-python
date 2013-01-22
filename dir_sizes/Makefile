CC_OPTS=-g
default: all

all: simple tuned

simple:
	gcc "$(CC_OPTS)" -I. -L. dirsize_simple.c -lccan -o dirsize_simple

tuned:
	gcc "$(CC_OPTS)" -I. -L. dirsize_tuned.c -lccan -o dirsize_tuned

