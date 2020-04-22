open Stdune

type metadata = Sexp.t list

module File = struct
  type t =
    { in_the_cache : Path.t
    ; in_the_build_directory : Path.Build.t
    ; digest : Digest.t
    }
end

type promotion =
  | Already_promoted of File.t
  | Promoted of File.t

type repository =
  { directory : string
  ; remote : string
  ; commit : string
  }

type command = Dedup of File.t

module Duplication_mode = struct
  type t =
    | Copy
    | Hardlink

  let all = [ ("copy", Copy); ("hardlink", Hardlink) ]

  let of_string repr =
    match List.assoc all repr with
    | Some mode -> Result.Ok mode
    | None -> Result.Error (Format.sprintf "invalid duplication mode: %s" repr)

  let to_string = function
    | Copy -> "copy"
    | Hardlink -> "hardlink"
end

module type Cache = sig
  type t

  (** Set the absolute path to the build directory for interpreting relative
      paths when promoting files. *)
  val set_build_dir : t -> Path.t -> t

  (** Set all the version controlled repositories in the workspace to be
      referred to when promoting files. *)
  val with_repositories : t -> repository list -> t

  (** Promote files produced by a build rule into the cache. *)
  val promote :
       t
    -> (Path.Build.t * Digest.t) list
    -> Key.t
    -> metadata
    -> repository:int option
    -> duplication:Duplication_mode.t option
    -> (unit, string) Result.t

  (** Find a build rule in the cache by its key. *)
  val search : t -> Key.t -> (metadata * File.t list, string) Result.t

  (** Materialise a cached file in the build directory (using [Copy] or
      [Hardlink] as per the duplication mode) and return the path to it. *)
  val retrieve : t -> File.t -> Path.t

  (** Deduplicate a file, i.e. replace the file [in_the_build_directory] with a
      hardlink to the one [in_the_cache] if the deduplication mode is set to
      [Hardlink] (or do nothing if the mode is [Copy]). *)
  val deduplicate : t -> File.t -> unit

  (** Remove the local cache and disconnect with a distributed cache client if
      any. *)
  val teardown : t -> unit
end

module type Caching = sig
  module Cache : Cache

  val cache : Cache.t
end

type caching = (module Caching)

let command_to_dyn = function
  | Dedup { in_the_build_directory; in_the_cache; digest } ->
    let open Dyn.Encoder in
    record
      [ ("in_the_build_directory", Path.Build.to_dyn in_the_build_directory)
      ; ("in_the_cache", Path.to_dyn in_the_cache)
      ; ("digest", Digest.to_dyn digest)
      ]
