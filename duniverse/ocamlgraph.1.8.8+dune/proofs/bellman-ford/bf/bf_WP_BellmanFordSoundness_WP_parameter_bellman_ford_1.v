(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.
Require int.MinMax.

(* Why3 assumption *)
Definition unit  := unit.

Parameter qtmark : Type.

Parameter at1: forall (a:Type), a -> qtmark -> a.
Implicit Arguments at1.

Parameter old: forall (a:Type), a -> a.
Implicit Arguments old.

(* Why3 assumption *)
Definition implb(x:bool) (y:bool): bool := match (x,
  y) with
  | (true, false) => false
  | (_, _) => true
  end.

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall (a:Type) (b:Type), (map a b) -> a -> b.
Implicit Arguments get.

Parameter set: forall (a:Type) (b:Type), (map a b) -> a -> b -> (map a b).
Implicit Arguments set.

Axiom Select_eq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall (b:Type) (a:Type), b -> (map a b).
Set Contextual Implicit.
Implicit Arguments const.
Unset Contextual Implicit.

Axiom Const : forall (b:Type) (a:Type), forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive ref (a:Type) :=
  | mk_ref : a -> ref a.
Implicit Arguments mk_ref.

(* Why3 assumption *)
Definition contents (a:Type)(v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.
Implicit Arguments contents.

Parameter set1 : forall (a:Type), Type.

Parameter mem: forall (a:Type), a -> (set1 a) -> Prop.
Implicit Arguments mem.

(* Why3 assumption *)
Definition infix_eqeq (a:Type)(s1:(set1 a)) (s2:(set1 a)): Prop :=
  forall (x:a), (mem x s1) <-> (mem x s2).
Implicit Arguments infix_eqeq.

Axiom extensionality : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)),
  (infix_eqeq s1 s2) -> (s1 = s2).

(* Why3 assumption *)
Definition subset (a:Type)(s1:(set1 a)) (s2:(set1 a)): Prop := forall (x:a),
  (mem x s1) -> (mem x s2).
Implicit Arguments subset.

Axiom subset_trans : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a))
  (s3:(set1 a)), (subset s1 s2) -> ((subset s2 s3) -> (subset s1 s3)).

Parameter empty: forall (a:Type), (set1 a).
Set Contextual Implicit.
Implicit Arguments empty.
Unset Contextual Implicit.

(* Why3 assumption *)
Definition is_empty (a:Type)(s:(set1 a)): Prop := forall (x:a), ~ (mem x s).
Implicit Arguments is_empty.

Axiom empty_def1 : forall (a:Type), (is_empty (empty :(set1 a))).

Parameter add: forall (a:Type), a -> (set1 a) -> (set1 a).
Implicit Arguments add.

Axiom add_def1 : forall (a:Type), forall (x:a) (y:a), forall (s:(set1 a)),
  (mem x (add y s)) <-> ((x = y) \/ (mem x s)).

Parameter remove: forall (a:Type), a -> (set1 a) -> (set1 a).
Implicit Arguments remove.

Axiom remove_def1 : forall (a:Type), forall (x:a) (y:a) (s:(set1 a)), (mem x
  (remove y s)) <-> ((~ (x = y)) /\ (mem x s)).

Axiom subset_remove : forall (a:Type), forall (x:a) (s:(set1 a)),
  (subset (remove x s) s).

Parameter union: forall (a:Type), (set1 a) -> (set1 a) -> (set1 a).
Implicit Arguments union.

Axiom union_def1 : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)) (x:a),
  (mem x (union s1 s2)) <-> ((mem x s1) \/ (mem x s2)).

Parameter inter: forall (a:Type), (set1 a) -> (set1 a) -> (set1 a).
Implicit Arguments inter.

Axiom inter_def1 : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)) (x:a),
  (mem x (inter s1 s2)) <-> ((mem x s1) /\ (mem x s2)).

Parameter diff: forall (a:Type), (set1 a) -> (set1 a) -> (set1 a).
Implicit Arguments diff.

Axiom diff_def1 : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)) (x:a),
  (mem x (diff s1 s2)) <-> ((mem x s1) /\ ~ (mem x s2)).

Axiom subset_diff : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)),
  (subset (diff s1 s2) s1).

Parameter all: forall (a:Type), (set1 a).
Set Contextual Implicit.
Implicit Arguments all.
Unset Contextual Implicit.

Axiom all_def : forall (a:Type), forall (x:a), (mem x (all :(set1 a))).

Parameter cardinal: forall (a:Type), (set1 a) -> Z.
Implicit Arguments cardinal.

Axiom cardinal_nonneg : forall (a:Type), forall (s:(set1 a)),
  (0%Z <= (cardinal s))%Z.

Axiom cardinal_empty : forall (a:Type), forall (s:(set1 a)),
  ((cardinal s) = 0%Z) <-> (is_empty s).

Axiom cardinal_add : forall (a:Type), forall (x:a), forall (s:(set1 a)),
  (~ (mem x s)) -> ((cardinal (add x s)) = (1%Z + (cardinal s))%Z).

Axiom cardinal_remove : forall (a:Type), forall (x:a), forall (s:(set1 a)),
  (mem x s) -> ((cardinal s) = (1%Z + (cardinal (remove x s)))%Z).

Axiom cardinal_subset : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)),
  (subset s1 s2) -> ((cardinal s1) <= (cardinal s2))%Z.

Parameter vertex : Type.

Parameter vertices: (set1 vertex).

Parameter s: vertex.

Parameter succ: vertex -> (set1 vertex).

Parameter weight: vertex -> vertex -> Z.

Axiom s_in_graph : (mem s vertices).

Axiom succ1 : forall (x:vertex), (mem x vertices) -> forall (y:vertex),
  (mem y (succ x)) -> (mem y vertices).

(* Why3 assumption *)
Inductive path : vertex -> vertex -> Z -> Prop :=
  | path_empty : forall (v:vertex), (path v v 0%Z)
  | path_succ : forall (v1:vertex) (v2:vertex) (v3:vertex) (n:Z), (path v1 v2
      n) -> ((mem v3 (succ v2)) -> (path v1 v3 (n + (weight v2 v3))%Z)).

(* Why3 assumption *)
Definition shortest_path(v1:vertex) (v2:vertex) (n:Z): Prop := (path v1 v2
  n) /\ forall (m:Z), (m <  n)%Z -> ~ (path v1 v2 m).

(* Why3 assumption *)
Definition no_path(v1:vertex) (v2:vertex): Prop := forall (n:Z), ~ (path v1
  v2 n).

(* Why3 assumption *)
Inductive reachable : vertex -> Z -> Prop :=
  | reach_empty : (reachable s 0%Z)
  | reach_succ : forall (v1:vertex) (v2:vertex) (n:Z), (reachable v1 n) ->
      ((mem v2 (succ v1)) -> (reachable v2 (n + 1%Z)%Z)).

(* Why3 assumption *)
Inductive dist  :=
  | Finite : Z -> dist 
  | Infinite : dist .

(* Why3 assumption *)
Definition infix_plpl(x:dist) (y:dist): dist :=
  match x with
  | Infinite => Infinite
  | (Finite x1) =>
      match y with
      | Infinite => Infinite
      | (Finite y1) => (Finite (x1 + y1)%Z)
      end
  end.

(* Why3 assumption *)
Definition infix_lsls(x:dist) (y:dist): Prop :=
  match x with
  | Infinite => False
  | (Finite x1) =>
      match y with
      | Infinite => True
      | (Finite y1) => (x1 <  y1)%Z
      end
  end.

(* Why3 assumption *)
Definition ge(x:dist) (y:dist): Prop :=
  match x with
  | Infinite => True
  | (Finite x1) =>
      match y with
      | Infinite => False
      | (Finite y1) => (y1 <= x1)%Z
      end
  end.

Parameter min: dist -> dist -> dist.

Parameter max: dist -> dist -> dist.

Axiom Max_is_ge : forall (x:dist) (y:dist), (ge (max x y) x) /\ (ge (max x y)
  y).

Axiom Max_is_some : forall (x:dist) (y:dist), ((max x y) = x) \/ ((max x
  y) = y).

Axiom Min_is_le : forall (x:dist) (y:dist), (ge x (min x y)) /\ (ge y (min x
  y)).

Axiom Min_is_some : forall (x:dist) (y:dist), ((min x y) = x) \/ ((min x
  y) = y).

Axiom Max_x : forall (x:dist) (y:dist), (ge x y) -> ((max x y) = x).

Axiom Max_y : forall (x:dist) (y:dist), (ge y x) -> ((max x y) = y).

Axiom Min_x : forall (x:dist) (y:dist), (ge y x) -> ((min x y) = x).

Axiom Min_y : forall (x:dist) (y:dist), (ge x y) -> ((min x y) = y).

Axiom Max_sym : forall (x:dist) (y:dist), (ge x y) -> ((max x y) = (max y
  x)).

Axiom Min_sym : forall (x:dist) (y:dist), (ge x y) -> ((min x y) = (min y
  x)).

Parameter take: forall (a:Type), (set1 a) -> a.
Implicit Arguments take.

Axiom take_def : forall (a:Type), forall (x:(set1 a)), (~ (is_empty x)) ->
  (mem (take x) x).

(* Why3 assumption *)
Definition bag (a:Type) := (ref (set1 a)).

(* Why3 assumption *)
Definition distmap  := (map vertex dist).

(* Why3 assumption *)
Definition paths(m:(map vertex dist)): Prop := forall (v:vertex), (mem v
  vertices) -> match (get m
  v) with
  | (Finite n) => (path s v n)
  | Infinite => True
  end.

(* Why3 goal *)
Theorem WP_parameter_bellman_ford : (paths (set (const Infinite:(map vertex
  dist)) s (Finite 0%Z))).

Require Import Classical.
unfold paths.
intros.
destruct (classic (v = s)).
rewrite Select_eq.
rewrite H0.
apply path_empty.
auto.
rewrite Select_neq.
rewrite Const.
auto.
auto.

Qed.


