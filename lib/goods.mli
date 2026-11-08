(** Goods are trade items (spices) that the player buys in shops and holds in
    their inventory. Goods give no combat strength; only counting towards the
    final score.

    A value of type [t] is one {e kind} of good (for example: Saffron), not a
    single item. Quantities are tracked by [Player]. *)

type t
(** One kind of good. Abstract, but safe to compare with [=]. *)

val name : t -> string
(** [name g] is the display name of [g], e.g. ["Saffron"]. Names are unique
    across [all]. *)

val description : t -> string
(** [description g] is a short flavor text for [g], shown in shops. *)

val price : t -> int
(** [price g] is the cost to buy one [g] in a shop. *)

val value : t -> int
(** [value g] is how much one [g] adds to the final score. *)

val all : t list
(** [all] is every good in the game, with no duplicates. *)

val of_name : string -> t option
(** [of_name s] is [Some g] if some good in [all] has name [s], and [None]
    otherwise. *)

val random_selection : Random.State.t -> int -> t list
(** Random chosen goods for shops to use to pick what to offer. *)

val inventory_value : (t * int) array -> int
(** inventory_value is the total score of the player's holdings . *)

val to_string : t -> string
(** one line summary for the menus *)
