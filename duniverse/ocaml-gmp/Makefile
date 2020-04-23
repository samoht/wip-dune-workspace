.PHONY: all clean

VERSION=6.1.2
NAME=gmp-${VERSION}
ARCHIVE=${NAME}.tar.xz
URL=https://gmplib.org/download/gmp/${ARCHIVE}
MD5=f58fa8001d60c4c77595fbbb62b63c1d

ifndef FETCH
  ifneq ($(shell command -v curl 2>/dev/null),)
    FETCH = curl -LSfs -o
  else
    FETCH = wget -O
  endif
endif

all: src
	@echo "=> ${NAME} is extracted in src/"
	dune build

clean:
	rm -rf src ${NAME}
	rm -f ${ARCHIVE}

src: ${ARCHIVE}
	tar xvfz ${ARCHIVE}
	mv ${NAME} src

${ARCHIVE}:
	${FETCH} ${ARCHIVE} ${URL}
