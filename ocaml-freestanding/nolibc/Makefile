ifeq ($(SYSDEP_OBJS),)
    $(error SYSDEP_OBJS not set)
endif

CC=${CC}
CFLAGS=-std=c99 -Wall -Wno-parentheses -Werror ${CFLAGS}-O2

OBJS=ctype.o \
     dtoa.o \
     memchr.o memcmp.o memcpy.o memmove.o memset.o \
     strcmp.o strlen.o strtol.o strchr.o strchrnul.o strncpy.o stpncpy.o \
     strstr.o \
     stubs.o \
     vfprintf.o vsnprintf.o snprintf.o fprintf.o printf.o

dtoa.o: CFLAGS+=-fno-strict-aliasing

libnolibc.a: $(OBJS) $(SYSDEP_OBJS)
	$(AR) rcs $@ $(OBJS) $(SYSDEP_OBJS)
