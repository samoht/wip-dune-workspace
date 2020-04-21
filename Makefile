.PHONY: all depends

all: depends
	dune build _build/mirage-hvt/Zarith/zarith.install

# these need to be installed before cflags-hvt is valid
depends:
	dune build _build/mirage-hvt/ocaml-solo5/solo5.install
	dune build _build/mirage-hvt/ocaml-freestanding/ocaml-freestanding.install
