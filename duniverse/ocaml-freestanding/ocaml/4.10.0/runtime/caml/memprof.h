/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*            Jacques-Henri Jourdan, projet Gallium, INRIA Paris          */
/*                                                                        */
/*   Copyright 2016 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#ifndef CAML_MEMPROF_H
#define CAML_MEMPROF_H

#ifdef CAML_INTERNALS

#include "config.h"
#include "mlvalues.h"
#include "roots.h"

extern int caml_memprof_suspended;

extern value caml_memprof_handle_postponed_exn();

extern void caml_memprof_track_alloc_shr(value block);
extern void caml_memprof_track_young(tag_t tag, uintnat wosize, int from_caml);
extern void caml_memprof_track_interned(header_t* block, header_t* blockend);

extern void caml_memprof_renew_minor_sample(void);
extern value* caml_memprof_young_trigger;

extern void caml_memprof_scan_roots(scanning_action f);

#endif

#endif /* CAML_MEMPROF_H */
