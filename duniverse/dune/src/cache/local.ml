open Stdune
open Result.O
open Cache_intf

type t =
  { root : Path.t
  ; build_root : Path.t option
  ; info : User_message.Style.t Pp.t list -> unit
  ; warn : User_message.Style.t Pp.t list -> unit
  ; repositories : repository list
  ; command_handler : command -> unit
  ; duplication_mode : Duplication_mode.t
  ; temp_dir : Path.t
  }

module Trimming_result = struct
  type t =
    { trimmed_files_size : int
    ; trimmed_files : Path.t list
    ; trimmed_metafiles : Path.t list
    }

  let empty =
    { trimmed_files_size = 0; trimmed_files = []; trimmed_metafiles = [] }

  let add t ~size ~file =
    { t with
      trimmed_files = file :: t.trimmed_files
    ; trimmed_files_size = size + t.trimmed_files_size
    }
end

let default_root () =
  Path.L.relative (Path.of_string Xdg.cache_dir) [ "dune"; "db" ]

let file_store_version = "v2"

let metadata_store_version = "v2"

let file_store_root cache =
  Path.L.relative cache.root [ "files"; file_store_version ]

let metadata_store_root cache =
  Path.L.relative cache.root [ "meta"; metadata_store_version ]

let detect_unexpected_dirs_under_cache_root cache =
  let expected_in_root path =
    (* We only report unexpected directories, since quite a few temporary files
       are created at the cache root, and it would be tedious to keep track of
       all of them. *)
    match (Path.is_directory (Path.relative cache.root path), path) with
    | false, _ -> true
    | true, "files"
    | true, "meta"
    | true, "runtime" ->
      true
    | true, dir -> String.is_prefix ~prefix:"promoting." dir
  in
  let open Result.O in
  let expected_in_files = String.equal file_store_version in
  let expected_in_meta = String.equal metadata_store_version in
  let detect_in ~dir expected =
    let+ names = Path.readdir_unsorted dir in
    List.filter_map names ~f:(fun name ->
        Option.some_if (not (expected name)) (Path.relative dir name))
  in
  let+ in_root = detect_in ~dir:cache.root expected_in_root
  and+ in_files =
    detect_in ~dir:(Path.relative cache.root "files") expected_in_files
  and+ in_meta =
    detect_in ~dir:(Path.relative cache.root "meta") expected_in_meta
  in
  List.sort ~compare:Path.compare (in_root @ in_files @ in_meta)

(* Handling file digest collisions by appending suffices ".1", ".2", etc. to the
   files stored in the cache.

   To find a cache entry matching a given file, we try the suffices one after
   another until we either (i) find a match and return [Found {existing_path}]
   where the [existing_path] includes the correct suffix, or (ii) find a suffix
   that is missing in the cache and return [Not_found {next_available_path}]
   where the [next_available_path] includes the first available suffix.

   CR-someday amokhov: In Dune we generally assume that digest collisions are
   impossible, so it seems better to remove this logic in future. *)
module Collision_chain = struct
  type search_result =
    | Found of { existing_path : Path.t }
    | Not_found of { next_available_path : Path.t }

  (* This function assumes that we do not create holes in the suffix numbering. *)
  let search path file =
    let rec loop n =
      let path = Path.extend_basename path ~suffix:("." ^ string_of_int n) in
      if Path.exists path then
        if Io.compare_files path file = Ordering.Eq then
          Found { existing_path = path }
        else
          loop (n + 1)
      else
        Not_found { next_available_path = path }
    in
    loop 1
end

(* A file storage scheme. *)
module type FSScheme = sig
  (* Given a cache root and a file digest, determine the location of the file in
     the cache. *)
  val path : root:Path.t -> Digest.t -> Path.t

  (* Extract a file's digest from its location in the cache. *)
  val digest : Path.t -> Digest.t

  (* Given a cache root, list all files stored in the cache. *)
  val list : root:Path.t -> Path.t list
end

(* A file storage scheme where a file with a digest [d] is stored in a
   subdirectory whose name is made of the first two characters of [d], that is:

   [<root>/<first-two-characters-of-d>/<d>.<N>]

   The suffix [.<N>] is used to handle collisions, i.e. the (unlikely)
   situations where two files have the same digest.

   CR-soon amokhov: Note that the function [path] returns the path without the
   [.<N>] suffix, whereas the function [digest] expects the [.<N>] suffix to be
   present. We should fix this inconsistency. *)
module FirstTwoCharsSubdir : FSScheme = struct
  let path ~root digest =
    let digest = Digest.to_string digest in
    let first_two_chars = String.sub digest ~pos:0 ~len:2 in
    Path.L.relative root [ first_two_chars; digest ]

  let digest path =
    match Digest.from_hex (Path.basename (fst (Path.split_extension path))) with
    | Some digest -> digest
    | None ->
      Code_error.raise "strange cached file path (not a valid digest)"
        [ (Path.to_string path, Path.to_dyn path) ]

  let list ~root =
    let f dir =
      let is_hex_char c =
        let char_in s e = Char.compare c s >= 0 && Char.compare c e <= 0 in
        char_in 'a' 'f' || char_in '0' '9'
      and root = Path.L.relative root [ dir ] in
      if String.for_all ~f:is_hex_char dir then
        Array.map ~f:(Path.relative root) (Sys.readdir (Path.to_string root))
      else
        Array.of_list []
    in
    Array.to_list
      (Array.concat
         (Array.to_list (Array.map ~f (Sys.readdir (Path.to_string root)))))
end

module FSSchemeImpl = FirstTwoCharsSubdir

module Metadata_file = struct
  type t =
    { metadata : Sexp.t list
    ; files : File.t list
    }

  let to_sexp { metadata; files } =
    let open Sexp in
    let f ({ in_the_build_directory; in_the_cache; _ } : File.t) =
      Sexp.List
        [ Sexp.Atom
            (Path.Local.to_string (Path.Build.local in_the_build_directory))
        ; Sexp.Atom (Path.to_string in_the_cache)
        ]
    in
    List
      [ List (Atom "metadata" :: metadata)
      ; List (Atom "files" :: List.map ~f files)
      ]

  let of_sexp = function
    | Sexp.List
        [ List (Atom "metadata" :: metadata); List (Atom "files" :: produced) ]
      ->
      let+ files =
        Result.List.map produced ~f:(function
          | List [ Atom in_the_build_directory; Atom in_the_cache ] ->
            let in_the_build_directory =
              Path.Build.of_string in_the_build_directory
            and in_the_cache = Path.of_string in_the_cache in
            Ok
              { File.in_the_cache
              ; in_the_build_directory
              ; digest = FSSchemeImpl.digest in_the_cache
              }
          | _ -> Error "invalid metadata scheme in produced files list")
      in
      { metadata; files }
    | _ -> Error "invalid metadata"

  let of_string s =
    match Csexp.parse_string s with
    | Ok sexp -> of_sexp sexp
    | Error (_, msg) -> Error msg

  let to_string f = to_sexp f |> Csexp.to_string

  let parse path = Io.with_file_in path ~f:Csexp.input >>= of_sexp
end

let metadata_path cache key =
  FSSchemeImpl.path ~root:(metadata_store_root cache) key

let file_path cache key = FSSchemeImpl.path ~root:(file_store_root cache) key

let make_path cache path =
  match cache.build_root with
  | Some p -> Result.ok (Path.append_local p path)
  | None ->
    Result.Error
      (sprintf "relative path %s while no build root was set"
         (Path.Local.to_string_maybe_quoted path))

let search cache digest file =
  Collision_chain.search (file_path cache digest) file

let with_repositories cache repositories = { cache with repositories }

let duplicate ?(duplication = None) cache ~src ~dst =
  match Option.value ~default:cache.duplication_mode duplication with
  | Copy -> Io.copy_file ~src ~dst ()
  | Hardlink -> Path.link src dst

let retrieve cache (file : File.t) =
  let path = Path.build file.in_the_build_directory in
  cache.info
    [ Pp.textf "retrieve %s from cache" (Path.to_string_maybe_quoted path) ];
  duplicate cache ~src:file.in_the_cache ~dst:path;
  path

let deduplicate cache (file : File.t) =
  match cache.duplication_mode with
  | Copy -> ()
  | Hardlink -> (
    let target = Path.Build.to_string file.in_the_build_directory in
    let tmpname = Path.Build.to_string (Path.Build.of_string ".dedup") in
    cache.info
      [ Pp.textf "deduplicate %s from %s" target
          (Path.to_string file.in_the_cache)
      ];
    let rm p = try Unix.unlink p with _ -> () in
    try
      rm tmpname;
      Unix.link (Path.to_string file.in_the_cache) tmpname;
      Unix.rename tmpname target
    with Unix.Unix_error (e, syscall, _) ->
      rm tmpname;
      cache.warn
        [ Pp.textf "error handling dune-cache command: %s: %s" syscall
            (Unix.error_message e)
        ] )

let apply ~f o v =
  match o with
  | Some o -> f v o
  | None -> v

let promote_sync cache paths key metadata ~repository ~duplication =
  let open Result.O in
  let* repo =
    match repository with
    | Some idx -> (
      match List.nth cache.repositories idx with
      | None -> Result.Error (Printf.sprintf "repository out of range: %i" idx)
      | repo -> Result.Ok repo )
    | None -> Result.Ok None
  in
  let metadata =
    apply
      ~f:(fun metadata repository ->
        metadata
        @ [ Sexp.List [ Sexp.Atom "repo"; Sexp.Atom repository.remote ]
          ; Sexp.List [ Sexp.Atom "commit_id"; Sexp.Atom repository.commit ]
          ])
      repo metadata
  in
  let promote (path, expected_digest) =
    let* abs_path = make_path cache (Path.Build.local path) in
    cache.info [ Pp.textf "promote %s" (Path.to_string abs_path) ];
    let stat = Unix.lstat (Path.to_string abs_path) in
    let* stat =
      if stat.st_kind = S_REG then
        Result.Ok stat
      else
        Result.Error
          (Format.sprintf "invalid file type: %s"
             (Path.string_of_file_kind stat.st_kind))
    in
    (* Create a duplicate (either a [Copy] or a [Hardlink] depending on the
       [duplication] setting) of the promoted file in a temporary directory to
       correctly handle the situation when the file is modified or deleted
       during the promotion process. *)
    let tmp =
      let dst = Path.relative cache.temp_dir "data" in
      if Path.exists dst then Path.unlink dst;
      duplicate ~duplication cache ~src:abs_path ~dst;
      dst
    in
    let effective_digest = Digest.file_with_stats tmp (Path.stat tmp) in
    if Digest.compare effective_digest expected_digest != Ordering.Eq then (
      let message =
        Printf.sprintf "digest mismatch: %s != %s"
          (Digest.to_string effective_digest)
          (Digest.to_string expected_digest)
      in
      cache.info [ Pp.text message ];
      Result.Error message
    ) else
      match search cache effective_digest tmp with
      | Collision_chain.Found { existing_path } ->
        (* We no longer need the temporary file. *)
        Path.unlink tmp;
        (* Update the timestamp of the existing cache entry, moving it to the
           back of the trimming queue. *)
        Path.touch existing_path;
        Result.Ok
          (Already_promoted
             { in_the_build_directory = path
             ; in_the_cache = existing_path
             ; digest = effective_digest
             })
      | Collision_chain.Not_found { next_available_path } ->
        Path.mkdir_p (Path.parent_exn next_available_path);
        let dest = Path.to_string next_available_path in
        (* Move the temporary file to the cache. *)
        Unix.rename (Path.to_string tmp) dest;
        (* Remove write permissions, making the cache entry immutable. We assume
           that users do not modify the files in the cache. *)
        Unix.chmod dest (stat.st_perm land 0o555);
        Result.Ok
          (Promoted
             { in_the_build_directory = path
             ; in_the_cache = next_available_path
             ; digest = effective_digest
             })
  in
  let+ promoted = Result.List.map ~f:promote paths in
  let metadata_path = metadata_path cache key
  and metadata_tmp_path = Path.relative cache.temp_dir "metadata"
  and files =
    List.map promoted ~f:(function
        | Already_promoted f
        | Promoted f
        -> f)
  in
  let metadata_file : Metadata_file.t = { metadata; files } in
  let metadata = Csexp.to_string (Metadata_file.to_sexp metadata_file) in
  Io.write_file metadata_tmp_path metadata;
  let () =
    match Io.read_file metadata_path with
    | contents ->
      if contents <> metadata then
        User_warning.emit
          [ Pp.textf "non reproductible collision on rule %s"
              (Digest.to_string key)
          ]
    | exception Sys_error _ -> Path.mkdir_p (Path.parent_exn metadata_path)
  in
  Path.rename metadata_tmp_path metadata_path;
  (* The files that have already been present in the cache can be deduplicated,
     i.e. replaced with hardlinks to their cached copies. *)
  ( match cache.duplication_mode with
  | Copy -> ()
  | Hardlink ->
    List.iter promoted ~f:(function
      | Already_promoted file -> cache.command_handler (Dedup file)
      | _ -> ()) );
  (metadata_file, promoted)

let promote cache paths key metadata ~repository ~duplication =
  Result.map ~f:ignore
    (promote_sync cache paths key metadata ~repository ~duplication)

let search cache key =
  let path = metadata_path cache key in
  let* sexp =
    try Io.with_file_in path ~f:Csexp.input
    with Sys_error _ -> Error "no cached file"
  in
  let+ metadata = Metadata_file.of_sexp sexp in
  (* Touch cache files so they are removed last by LRU trimming. *)
  let () =
    let f (file : File.t) =
      (* There is no point in trying to trim out files that are missing : dune
         will have to check when hardlinking anyway since they could disappear
         inbetween. *)
      try Path.touch ~create:false file.in_the_cache
      with Unix.(Unix_error (ENOENT, _, _)) -> ()
    in
    List.iter ~f metadata.files
  in
  (metadata.metadata, metadata.files)

let set_build_dir cache p = { cache with build_root = Some p }

let teardown cache = Path.rm_rf ~allow_external:true cache.temp_dir

let detect_duplication_mode root =
  let () = Path.mkdir_p root in
  let beacon = Path.relative root "beacon"
  and target = Path.relative Path.build_dir ".cache-beacon" in
  let () = Path.touch beacon in
  let rec test () =
    match Path.link beacon target with
    | exception Unix.Unix_error (Unix.EEXIST, _, _) ->
      Path.unlink_no_err target;
      test ()
    | exception Unix.Unix_error _ -> Duplication_mode.Copy
    | () -> Duplication_mode.Hardlink
  in
  test ()

let make ?(root = default_root ())
    ?(duplication_mode = detect_duplication_mode root)
    ?(log = Dune_util.Log.info) ?(warn = fun pp -> User_warning.emit pp)
    ~command_handler () =
  let res =
    { root
    ; build_root = None
    ; info = log
    ; warn
    ; repositories = []
    ; command_handler
    ; duplication_mode
    ; temp_dir =
        (* CR-soon amokhov: Introduce [val getpid : unit -> t] in [pid.ml] so
           that we don't use the untyped version of pid anywhere. *)
        Path.temp_dir ~temp_dir:root "promoting."
          ("." ^ string_of_int (Unix.getpid ()))
    }
  in
  match
    Path.mkdir_p @@ file_store_root res;
    Path.mkdir_p @@ metadata_store_root res
  with
  | () -> Ok res
  | exception exn ->
    Error
      ("Unable to set up the cache root directory: " ^ Printexc.to_string exn)

let duplication_mode cache = cache.duplication_mode

let trimmable stats = stats.Unix.st_nlink = 1

let _garbage_collect default_trim cache =
  let root = metadata_store_root cache in
  let metas =
    List.map ~f:(fun p -> (p, Metadata_file.parse p)) (FSSchemeImpl.list ~root)
  in
  let f default_trim = function
    | p, Result.Error msg ->
      cache.warn
        [ Pp.textf "remove invalid metadata file %s: %s"
            (Path.to_string_maybe_quoted p)
            msg
        ];
      Path.unlink_no_err p;
      { default_trim with Trimming_result.trimmed_metafiles = [ p ] }
    | p, Result.Ok { Metadata_file.files; _ } ->
      if
        List.for_all
          ~f:(fun { File.in_the_cache; _ } -> Path.exists in_the_cache)
          files
      then
        default_trim
      else (
        cache.info
          [ Pp.textf
              "remove metadata file %s as some produced files are missing"
              (Path.to_string_maybe_quoted p)
          ];
        let res =
          List.fold_left ~init:default_trim
            ~f:(fun trim f ->
              let p = f.File.in_the_cache in
              try
                let stats = Path.stat p in
                if trimmable stats then (
                  Path.unlink_no_err p;
                  Trimming_result.add trim ~file:p ~size:stats.st_size
                ) else
                  trim
              with Unix.Unix_error (Unix.ENOENT, _, _) -> trim)
            files
        in
        Path.unlink_no_err p;
        res
      )
  in
  List.fold_left ~init:default_trim ~f metas

let garbage_collect = _garbage_collect Trimming_result.empty

let trim cache free =
  let root = file_store_root cache in
  let files = FSSchemeImpl.list ~root in
  let f path =
    let stats = Path.stat path in
    if trimmable stats then
      Some (path, stats.st_size, stats.st_mtime)
    else
      None
  and compare (_, _, t1) (_, _, t2) = Ordering.of_int (Stdlib.compare t1 t2) in
  let files = List.sort ~compare (List.filter_map ~f files)
  and delete (trim : Trimming_result.t) (path, size, _) =
    if trim.trimmed_files_size >= free then
      trim
    else (
      Path.unlink path;
      Trimming_result.add trim ~size ~file:path
    )
  in
  let trim = List.fold_left ~init:Trimming_result.empty ~f:delete files in
  _garbage_collect trim cache

let overhead_size cache =
  let root = file_store_root cache in
  let files = FSSchemeImpl.list ~root in
  let stats =
    let f p =
      try
        let stats = Path.stat p in
        if trimmable stats then
          stats.st_size
        else
          0
      with Unix.Unix_error (Unix.ENOENT, _, _) -> 0
    in
    List.map ~f files
  in
  List.fold_left ~f:(fun acc size -> acc + size) ~init:0 stats
