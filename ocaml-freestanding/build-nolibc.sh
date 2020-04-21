#!/bin/sh -eux

CC=$1
shift
CFLAGS=$@

make CC="${CC}" CFLAGS="${CFLAGS}" SYSDEP_OBJS=sysdeps_solo5.o
