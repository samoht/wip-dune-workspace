// Fom https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/gmpTutorial.html
// and https://www.linux-nantes.org/~fmonnier/OCaml/ocaml-wrapping-c.html#ref_hello_world

#include "gmp.h"
#include <stdio.h>
#include <caml/mlvalues.h>

void fact(int n){
  int i;
  mpz_t p;

  mpz_init_set_ui(p,1); /* p = 1 */
  for (i=1; i <= n ; ++i){
    mpz_mul_ui(p,p,i); /* p = p * i */
  }
  printf ("%d!  =  ", n);
  mpz_out_str(stdout,10,p);
  mpz_clear(p);

}

CAMLprim value
caml_fact(value unit)
{
    fact(10);
    return Val_unit;
}
