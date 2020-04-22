.PHONY: all depends

all: depends
	dune build _build/mirage-hvt/duniverse/Zarith/zarith.install

# these need to be installed before cflags-hvt is valid
depends:
	dune build _build/mirage-hvt/duniverse/ocaml-solo5/solo5.install
	dune build _build/mirage-hvt/duniverse/ocaml-freestanding/ocaml-freestanding.install
