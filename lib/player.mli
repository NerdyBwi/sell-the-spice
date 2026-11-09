type t

val init_player : string -> int -> int -> int -> int -> int -> t
(** [init_player name initial_hp initial_atk initial_gold deck_size goods_size]
    generates a player with an initial state of the provided values. *)

val get_name : t -> string
(** Retrieves the name of the player. *)

(* ============================================================================
   Health functions
   ============================================================================ *)

val get_hp : t -> int
(** Retrieves the current HP of a player. *)

val get_max_hp : t -> int
(** Retrieves the max HP of a player. *)

val add_hp : int -> t -> (unit, string) result
(** [add_hp num player] adds that number of HP to the player's HP stat. Works
    with negative integer inputs for subtraction, and allows negative HP. Only
    allows for modification of positive HP. *)

val add_max_hp : int -> t -> (unit, string) result
(** [add_max_hp num player] adds that number of HP to the player's max HP stat.
    Works with negative integer inputs for subtraction. Will lower the player's
    current hp, but will not lower it below 1. Will not increase player's
    current hp. Does not allow negative max HP. Does not work on dead players.
*)

val check_alive : t -> bool
(** [check_alive player] checks if the player's HP is positive. Returns [true]
    if it is.*)

(* ============================================================================
   Gold functions
   ============================================================================ *)

val get_gold : t -> int
(** Retrieves the number of gold the player has. *)

val add_gold : int -> t -> (unit, string) result
(** [add_gold num player] adds that number of gold to the player's gold stat.
    Works with negative integer inputs for subtraction. Does not allow a
    modification that would result in a negative gold balance. *)

(* ============================================================================
   Attack functions
   ============================================================================ *)

val get_atk : t -> int
(** Retrieves the attack stat of a player. *)

val add_atk : int -> t -> (unit, string) result
(** [add_atk num player] adds that number of atk to the player's atk stat. Works
    with negative integer inputs for subtraction. Does not allow a modification
    that would result in a negative atk value. *)

(* ============================================================================
   Deck functions
   ============================================================================ *)

val get_deck : t -> Cards.t array
(** Retrieves the deck of cards in a player's inventory. Does not contain empty
    deck slots. *)

val get_deck_size : t -> int
(** Retrieves the max size of the deck of cards in the player's inventory. *)

val add_card : Cards.t -> t -> (unit, string) result
(** [add_card card player] adds that cards to a player's deck. Returns an Error
    if the player has no more deck slots. *)

val remove_card : Cards.t -> t -> (unit, string) result
(** [remove_card card player] removes that card from the player's deck. Returns
    an Error if the deck does not contain that card. *)

val shuffle_deck : Random.State.t -> t -> (unit, string) result
(**[shuffle_deck rand_state player] takes a random state and shuffles the
   player's deck of cards. *)

val add_deck_size : int -> t -> (unit, string) result
(** [add_deck_size num player] adds [num] deck slots to the player's deck. Works
    with negative integers. Does not allow for a modification that would result
    in less slots than currently held cards. Does not allow for a modification
    that would result in a negative number of deck slots. *)

(* ============================================================================
   Goods functions
   ============================================================================ *)

val get_goods : t -> (Goods.t * int) array
(** Retrieves the player's goods inventory. Each entry contains the good and the
    count of the good. Does not contain empty inventory slots. *)

val get_goods_size : t -> int
(** Retrieves the max size of the player's goods inventory. *)

val add_good : Goods.t -> int -> t -> (unit, string) result
(** [add_good good count player] adds that number of goods to a player's
    inventory. Does not modify the player's stats.

    If the count is negative, returns [Error error_str_negative_good_add_count].

    If the player has no more inventory slots, returns
    [Error error_str_no_good_slots]. *)

val remove_good_amount : Goods.t -> int -> t -> (unit, string) result
(** [remove_good_amount good count player] removes a number of goods from a
    player's inventory. Does not modify the player's stats.

    If the count is negative, returns
    [Error error_str_negative_good_remove_count].

    If the good was not found, returns [Error error_str_unfound_good_remove].

    If the count exceeds the held amount, returns
    [Error error_str_excess_good_remove]*)

val remove_good : Goods.t -> t -> (int, string) result
(** [remove_good good player] removes all of the goods from the player's
    inventory with that associated name. Does not modify the player's stats.
    Returns the number of goods removed from the player if successful.

    If the good was not found, returns [Error error_str_unfound_good_remove].*)

val add_good_size : int -> t -> (unit, string) result
(** [add_good_size num player] adds [num] inventory slots to the player's goods
    inventory. Works with negative integers. Does not allow for a modification
    that would result in less slots than currently held items. Does not allow
    for a modification that would result in a negative number of inventory
    slots. *)

val error_str_unfound_good_remove : string
(** Error string given when a good cannot be found in the inventory*)

val error_str_excess_good_remove : string
(** Error string given when removing this amount of good results in negative
    count in the inventory*)

val error_str_no_good_slots : string
(** Error string given when there are no empty inventory slots for adding a
    good.*)

val error_str_negative_good_add_count : string
(** Error string given when attempting to add a negative number of goods.*)

val error_str_negative_good_remove_count : string
(** Error string given when attempting to add a negative number of goods.*)
