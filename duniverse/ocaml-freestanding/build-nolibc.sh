#!/bin/sh -eux

CC_=$1
shift
CFLAGS=$@

make CC="cc" CFLAGS="${CFLAGS}" SYSDEP_OBJS=sysdeps_solo5.o
