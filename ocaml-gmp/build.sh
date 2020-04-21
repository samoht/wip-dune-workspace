#!/bin/sh -ex

# autoconf host == dune target
TARGET=$1
shift
CC=$1
shift
CFLAGS=$@

cd src/

ac_cv_func_obstack_vprintf=no \
ac_cv_func_localeconv=no \
./configure \
    --host=$TARGET --enable-fat --disable-shared --with-pic \
    CC=$CC "CPPFLAGS=$CFLAGS"

make SUBDIRS="mpn mpz mpq mpf" \
    PRINTF_OBJECTS= SCANF_OBJECTS= \
    CFLAGS+=-Werror=implicit-function-declaration

cp .libs/libgmp.a ..
cp gmp.h ..
