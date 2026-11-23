type item
(** Variant of cards/goods/anything else in shop*)

type purchase_result =
| Purchased
| Empty_slot
| Not_enough_gold

type t
(** Shop type, contains an array of item/price tuple*)

val init_shop : Random.State.t -> t
(** Takes in rng seed to generate shop *)

val get_price : t -> int -> int option
(** Takes in shop and index of item and returns price*)

val purchase_item : t -> int -> Player.t -> purchase_result
(** Takes in index of item and shop and returns *)
