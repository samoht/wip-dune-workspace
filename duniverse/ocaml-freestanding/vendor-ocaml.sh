#!/bin/sh -eux

OCAML_VERSIONS="4.08.0 4.08.1 4.09.0 4.09.1 4.10.0"

rm -rf ocaml
for version in ${OCAML_VERSIONS}; do
    git subtree add --prefix ocaml/${version} \
        https://github.com/ocaml/ocaml.git ${version} --squash
    git reset HEAD^
done
find ocaml -name "dune*" -delete
git add ocaml
git commit ocaml -m "Adding OCaml versions: ${OCAML_VERSIONS}"
