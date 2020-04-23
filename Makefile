-include Makefile.user

OPAM = opam

DEPEXT ?= $(OPAM) pin add -k path --no-action --yes https . && \
	    $(OPAM) depext --yes --update https ;\
	    $(OPAM) pin remove --no-action https

.PHONY: all depend depends clean build

all:: build

depend depends::
	$(DEPEXT)
	$(OPAM) install -y --deps-only .

build::
	dune build @_build/mirage-hvt/duniverse/ocaml-solo5/install
	dune build @_build/mirage-hvt/duniverse/ocaml-freestanding/install
	dune build _build/mirage-hvt/https.hvt

clean::
	mirage clean
