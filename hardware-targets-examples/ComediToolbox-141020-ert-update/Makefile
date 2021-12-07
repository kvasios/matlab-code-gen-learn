SF=$(wildcard sfun_*.c)

MEX = $(SF:%.c=%.mexa64)

all: $(MEX)

%.mexa64: %.c
	mex $(CFLAGS) $^

MATLAB=$(shell cd $(dir $(shell readlink -f $$(which mex)))/..; pwd)
