/*
 * Copyright 2007-2008 The MathWorks, Inc.
 *
 * File: rtiostream_loadlib.h     $Revision: 8771 $
 *
 * Abstract: Header for use with utility functions for loading shared library
 */

/* =========================== Typedefs ==================================*/

typedef int (*rtIOStreamOpen_type)(const int, void **);
typedef int (*rtIOStreamSend_type)(const int, const void *, const size_t, size_t *);
typedef int (*rtIOStreamRecv_type)(const int, void *, const size_t, size_t *);
typedef int (*rtIOStreamClose_type)(const int);

typedef struct libH_type_tag {
    rtIOStreamOpen_type openFn;
    rtIOStreamSend_type sendFn;
    rtIOStreamRecv_type recvFn;
    rtIOStreamClose_type closeFn;
    void * handle;
} libH_type;

