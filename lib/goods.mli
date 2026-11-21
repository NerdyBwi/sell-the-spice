(** Goods are trade items (spices) that the player buys in shops and holds in
    their inventory. Goods give no combat strength; they only count towards the
    final score.

    A value of type [t] is one {e kind} of good (for example: Saffron), not a
    single item. Quantities are tracked by [Player]. Two goods are equal under
    [=] exactly when they are the same kind. *)

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
(** [value g] is how much one [g] adds to the final score. Never negative. *)

val all : t list
(** [all] is every good in the game, cheapest first, with no duplicates. *)

val of_name : string -> t option
(** [of_name s] is [Some g] if the good [g] in [all] has name [s] (exact,
    case-sensitive match), and [None] otherwise. *)

val random_selection : Random.State.t -> int -> t list
(** [random_selection rng n] is [min n (List.length all)] distinct goods chosen
    at random from [all] using [rng], for a shop to offer. Two states created
    from the same seed give the same result. Raises [Invalid_argument] if
    [n < 0]. *)

val inventory_value : (t * int) array -> int
(** [inventory_value inv] is the sum of [value g * count] over every
    [(g, count)] in [inv]; [0] for an empty array. Takes the shape that
    [Player.get_goods] returns. *)

val to_string : t -> string
(** [to_string g] is a one-line summary of [g] for menus, giving its name,
    price and description, e.g.
    ["Saffron (30 gold): Red threads picked by hand. Worth a fortune."]. *)
