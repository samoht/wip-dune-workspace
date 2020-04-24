#!/bin/sh -ex

# autoconf host == dune target
TARGET=$1
shift
CC_=$1
shift
CFLAGS_=$@

cd src

ac_cv_func_obstack_vprintf=no \
ac_cv_func_localeconv=no \
./configure \
    --host=$TARGET --enable-fat --disable-shared --with-pic=no \
    CC=cc CPPFLAGS="${CFLAGS_} -fno-stack-protector"

make SUBDIRS="mpn mpz mpq mpf" \
    PRINTF_OBJECTS= SCANF_OBJECTS= \
    CPPFLAGS="${CFLAGS_}" \
    CFLAGS+=-Werror=implicit-function-declaration

cp .libs/libgmp.a ..
cp gmp.h ..
