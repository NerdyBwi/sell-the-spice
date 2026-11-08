(** Goods are trade items (spices) that the player buys in shops and holds in
    their inventory. Goods give no combat strength; they only count toward the
    final score.

    A value of type [t] is one {e kind} of good (e.g. Saffron), not a single
    item. Quantities are tracked by [Player]. Two goods are equal under [=]
    exactly when they are the same kind. *)

type t
(** One kind of good. Abstract, but safe to compare with [=]. *)

val name : t -> string
(** [name g] is the display name of [g], e.g. ["Saffron"]. Names are unique
    across [all]. *)

val description : t -> string
(** [description g] is a short flavor text for [g], shown in shops. *)

val price : t -> int
(** [price g] is the gold cost to buy one [g] in a shop. Always positive. *)

val value : t -> int
(** [value g] is how much one [g] adds to the final score. Always
    non-negative. *)

val all : t list
(** [all] is every good in the game, with no duplicates. *)

val of_name : string -> t option
(** [of_name s] is [Some g] if some good in [all] has name [s] (ignoring case),
    and [None] otherwise. *)

val random_selection : Random.State.t -> int -> t list
(** [random_selection rng n] is [min n (List.length all)] distinct goods chosen
    at random from [all] using [rng]. Shops use it to pick what to offer.
    Raises [Invalid_argument] if [n < 0]. *)

val inventory_value : (t * int) array -> int
(** [inventory_value inv] is the total score of [inv]: the sum of
    [value g * count] over every entry [(g, count)]. Takes the same shape that
    [Player.get_goods] returns. *)

val to_string : t -> string
(** [to_string g] is a one-line summary of [g] for menus, such as
    ["Saffron (12 gold): Worth its weight in gold."]. *)
