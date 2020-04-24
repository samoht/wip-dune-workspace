;; SOLO5

; a dummy OCaml library is needed because of ocaml/dune#3378
(library
  (public_name solo5)
  (name solo5)
  (modules))

(rule
 (targets
   solo5-elftool
   solo5-cflags
   elf_abi.h
   hvt_abi.h
   mft_abi.h
   solo5.h
   solo5_version.h
   spt_abi.h
   float.h
   stdarg.h
   stddef.h
   iso646.h
   stdbool.h
   stdint.h
   stdint-gcc.h
   stdalign.h
   stdnoreturn.h
   x86intrin.h
   clzerointrin.h
   cpuid.h
   adxintrin.h
   ammintrin.h
   avx2intrin.h
   avx5124fmapsintrin.h
   avx5124vnniwintrin.h
   avx512bitalgintrin.h
   avx512bwintrin.h
   avx512cdintrin.h
   avx512dqintrin.h
   avx512erintrin.h
   avx512fintrin.h
   avx512ifmaintrin.h
   avx512ifmavlintrin.h
   avx512pfintrin.h
   avx512vbmi2intrin.h
   avx512vbmi2vlintrin.h
   avx512vbmiintrin.h
   avx512vbmivlintrin.h
   avx512vlbwintrin.h
   avx512vldqintrin.h
   avx512vlintrin.h
   avx512vnniintrin.h
   avx512vnnivlintrin.h
   avx512vpopcntdqintrin.h
   avx512vpopcntdqvlintrin.h
   avxintrin.h
   bmi2intrin.h
   bmiintrin.h
   cetintrin.h
   cldemoteintrin.h
   clflushoptintrin.h
   clwbintrin.h
   emmintrin.h
   f16cintrin.h
   fma4intrin.h
   fmaintrin.h
   fxsrintrin.h
   gfniintrin.h
   ia32intrin.h
   immintrin.h
   lwpintrin.h
   lzcntintrin.h
   mm3dnow.h
   mm_malloc.h
   mmintrin.h
   movdirintrin.h
   mwaitxintrin.h
   pconfigintrin.h
   pkuintrin.h
   pmmintrin.h
   popcntintrin.h
   prfchwintrin.h
   rdseedintrin.h
   rtmintrin.h
   sgxintrin.h
   shaintrin.h
   smmintrin.h
   tbmintrin.h
   tmmintrin.h
   vaesintrin.h
   vpclmulqdqintrin.h
   waitpkgintrin.h
   wbnoinvdintrin.h
   wmmintrin.h
   xmmintrin.h
   xopintrin.h
   xsavecintrin.h
   xsaveintrin.h
   xsaveoptintrin.h
   xsavesintrin.h
   xtestintrin.h)
 (deps build.exe (source_tree src))
 (package solo5)
 (action (bash "./build.exe solo5 $(realpath $(dirname %{lib:solo5:dune-package}))")))

(install
  (files
   (solo5-cflags as cflags)
   (elf_abi.h as solo5/elf_abi.h)
   (hvt_abi.h as solo5/hvt_abi.h)
   (mft_abi.h as solo5/mft_abi.h)
   (solo5.h as solo5/solo5.h)
   (solo5_version.h as solo5/solo5_version.h)
   (spt_abi.h as solo5/spt_abi.h)
   (float.h as crt/float.h)
   (stdarg.h as crt/stdarg.h)
   (stddef.h as crt/stddef.h)
   (iso646.h as crt/iso646.h)
   (stdbool.h as crt/stdbool.h)
   (stdint.h as crt/stdint.h)
   (stdint-gcc.h as crt/stdint-gcc.h)
   (stdalign.h as crt/stdalign.h)
   (stdnoreturn.h as crt/stdnoreturn.h)
   (x86intrin.h as crt/x86intrin.h)
   (clzerointrin.h as crt/clzerointrin.h)
   (cpuid.h as crt/cpuid.h)
   (adxintrin.h as crt/adxintrin.h)
   (ammintrin.h as crt/ammintrin.h)
   (avx2intrin.h as crt/avx2intrin.h)
   (avx5124fmapsintrin.h as crt/avx5124fmapsintrin.h)
   (avx5124vnniwintrin.h as crt/avx5124vnniwintrin.h)
   (avx512bitalgintrin.h as crt/avx512bitalgintrin.h)
   (avx512bwintrin.h as crt/avx512bwintrin.h)
   (avx512cdintrin.h as crt/avx512cdintrin.h)
   (avx512dqintrin.h as crt/avx512dqintrin.h)
   (avx512erintrin.h as crt/avx512erintrin.h)
   (avx512fintrin.h as crt/avx512fintrin.h)
   (avx512ifmaintrin.h as crt/avx512ifmaintrin.h)
   (avx512ifmavlintrin.h as crt/avx512ifmavlintrin.h)
   (avx512pfintrin.h as crt/avx512pfintrin.h)
   (avx512vbmi2intrin.h as crt/avx512vbmi2intrin.h)
   (avx512vbmi2vlintrin.h as crt/avx512vbmi2vlintrin.h)
   (avx512vbmiintrin.h as crt/avx512vbmiintrin.h)
   (avx512vbmivlintrin.h as crt/avx512vbmivlintrin.h)
   (avx512vlbwintrin.h as crt/avx512vlbwintrin.h)
   (avx512vldqintrin.h as crt/avx512vldqintrin.h)
   (avx512vlintrin.h as crt/avx512vlintrin.h)
   (avx512vnniintrin.h as crt/avx512vnniintrin.h)
   (avx512vnnivlintrin.h as crt/avx512vnnivlintrin.h)
   (avx512vpopcntdqintrin.h as crt/avx512vpopcntdqintrin.h)
   (avx512vpopcntdqvlintrin.h as crt/avx512vpopcntdqvlintrin.h)
   (avxintrin.h as crt/avxintrin.h)
   (bmi2intrin.h as crt/bmi2intrin.h)
   (bmiintrin.h as crt/bmiintrin.h)
   (cetintrin.h as crt/cetintrin.h)
   (cldemoteintrin.h as crt/cldemoteintrin.h)
   (clflushoptintrin.h as crt/clflushoptintrin.h)
   (clwbintrin.h as crt/clwbintrin.h)
   (emmintrin.h as crt/emmintrin.h)
   (f16cintrin.h as crt/f16cintrin.h)
   (fma4intrin.h as crt/fma4intrin.h)
   (fmaintrin.h as crt/fmaintrin.h)
   (fxsrintrin.h as crt/fxsrintrin.h)
   (gfniintrin.h as crt/gfniintrin.h)
   (ia32intrin.h as crt/ia32intrin.h)
   (immintrin.h as crt/immintrin.h)
   (lwpintrin.h as crt/lwpintrin.h)
   (lzcntintrin.h as crt/lzcntintrin.h)
   (mm3dnow.h as crt/mm3dnow.h)
   (mm_malloc.h as crt/mm_malloc.h)
   (mmintrin.h as crt/mmintrin.h)
   (movdirintrin.h as crt/movdirintrin.h)
   (mwaitxintrin.h as crt/mwaitxintrin.h)
   (pconfigintrin.h as crt/pconfigintrin.h)
   (pkuintrin.h as crt/pkuintrin.h)
   (pmmintrin.h as crt/pmmintrin.h)
   (popcntintrin.h as crt/popcntintrin.h)
   (prfchwintrin.h as crt/prfchwintrin.h)
   (rdseedintrin.h as crt/rdseedintrin.h)
   (rtmintrin.h as crt/rtmintrin.h)
   (sgxintrin.h as crt/sgxintrin.h)
   (shaintrin.h as crt/shaintrin.h)
   (smmintrin.h as crt/smmintrin.h)
   (tbmintrin.h as crt/tbmintrin.h)
   (tmmintrin.h as crt/tmmintrin.h)
   (vaesintrin.h as crt/vaesintrin.h)
   (vpclmulqdqintrin.h as crt/vpclmulqdqintrin.h)
   (waitpkgintrin.h as crt/waitpkgintrin.h)
   (wbnoinvdintrin.h as crt/wbnoinvdintrin.h)
   (wmmintrin.h as crt/wmmintrin.h)
   (xmmintrin.h as crt/xmmintrin.h)
   (xopintrin.h as crt/xopintrin.h)
   (xsavecintrin.h as crt/xsavecintrin.h)
   (xsaveintrin.h as crt/xsaveintrin.h)
   (xsaveoptintrin.h as crt/xsaveoptintrin.h)
   (xsavesintrin.h as crt/xsavesintrin.h)
   (xtestintrin.h as crt/xtestintrin.h))
  (section lib)
  (package solo5))

(install
  (files solo5-elftool)
  (section bin)
  (package solo5))

;; HVT

; a dummy OCaml library is needed because of ocaml/dune#3378
(library
  (public_name solo5-hvt)
  (name hvt)
  (libraries solo5)
  (modules))

(rule
 (targets
   solo5-hvt
   solo5-hvt-configure
   solo5-hvt-debug
   solo5_hvt.o
   solo5_hvt.lds
   hvt-cflags
   hvt-ldflags)
 (deps cflags.pc.in ldflags.pc.in build.exe (source_tree src))
 (package solo5-hvt)
 (action (bash "./build.exe hvt $(realpath $(dirname %{lib:solo5-hvt:dune-package}))")))

(install
  (files
   solo5_hvt.o
   solo5_hvt.lds
   (hvt-cflags as cflags)
   (hvt-ldflags as ldflags))
  (section lib)
  (package solo5-hvt))

(install
  (files solo5-hvt solo5-hvt-configure solo5-hvt-debug)
  (section bin)
  (package solo5-hvt))

;; SPT

; a dummy OCaml library is needed because of ocaml/dune#3378
(library
  (public_name solo5-spt)
  (name spt)
  (libraries solo5)
  (modules))

(rule
 (targets solo5-spt solo5_spt.o solo5_spt.lds spt-cflags spt-ldflags)
 (deps cflags.pc.in ldflags.pc.in build.exe (source_tree src))
 (package solo5-spt)
 (action (bash "./build.exe spt $(realpath $(dirname %{lib:solo5-spt:dune-package}))")))

(install
  (files
   solo5_spt.o
   solo5_spt.lds
   (spt-cflags as cflags)
   (spt-ldflags as ldflags))
  (section lib)
  (package solo5-spt))

(install
  (files solo5-spt)
  (section bin)
  (package solo5-spt))

;; VIRTIO

; a dummy OCaml library is needed because of ocaml/dune#3378
(library
  (public_name solo5-virtio)
  (name virtio)
  (libraries solo5)
  (modules))

(rule
 (targets
   solo5-virtio-mkimage.sh
   solo5-virtio-run.sh
   solo5_virtio.o
   solo5_virtio.lds
   virtio-cflags
   virtio-ldflags)
 (deps cflags.pc.in ldflags.pc.in build.exe (source_tree src))
 (package solo5-virtio)
 (action (bash "./build.exe virtio $(realpath $(dirname %{lib:solo5-virtio:dune-package}))")))

(install
  (files
   solo5_virtio.o
   solo5_virtio.lds
   (virtio-cflags as cflags)
   (virtio-ldflags as ldflags))
  (section lib)
  (package solo5-virtio))

(install
  (files
   (solo5-virtio-mkimage.sh as solo5-virtio-mkimage)
   (solo5-virtio-run.sh as solo5-virtio-run))
  (section bin)
  (package solo5-virtio))

;; MUEN

; a dummy OCaml library is needed because of ocaml/dune#3378
(library
  (public_name solo5-muen)
  (name muen)
  (libraries solo5)
  (modules))

(rule
 (targets solo5_muen.o solo5_muen.lds muen-cflags muen-ldflags)
 (deps cflags.pc.in ldflags.pc.in build.exe (source_tree src))
 (package solo5-muen)
 (action (bash "./build.exe muen $(realpath $(dirname %{lib:solo5-muen:dune-package}))")))

(install
  (files
   solo5_muen.o
   solo5_muen.lds
   (muen-cflags as cflags)
   (muen-ldflags as ldflags))
  (section lib)
  (package solo5-muen))

;; GENODE

; a dummy OCaml library is needed because of ocaml/dune#3378
(library
  (public_name solo5-genode)
  (name genode)
  (libraries solo5)
  (modules))

(rule
 (targets solo5.lib.so genode_dyn.ld genode-cflags genode-ldflags)
 (deps genode-cflags.pc.in genode-ldflags.pc.in build.exe (source_tree src))
 (package solo5-genode)
 (action (bash "./build.exe genode $(realpath $(dirname %{lib:solo5-genode:dune-package}))")))

(install
  (files
   solo5.lib.so
   genode_dyn.ld
   (genode-cflags as cflags)
   (genode-ldflags as ldflags))
  (section lib)
  (package solo5-genode))
