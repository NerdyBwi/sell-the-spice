type t
(** Shop type, contains an array of items*)

type item
(** Record containing the type (Variant of cards/goods/anything else in shop)
and its associated price*)


val init_shop : Random.State.t -> t
(** Takes in rng seed to generate shop *)

val purchase_item : int -> t -> (result, t)
(** Takes in index of item and shop and returns *)



