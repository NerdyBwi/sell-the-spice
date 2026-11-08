type t

val init_player : string -> int -> int -> int -> int -> int -> t
(** [init_player name hp atk gold initial_deck_size initial_goods_size]
    generates a player with an initial state of the provided values. *)

val get_name : t -> string
(** Retrieves the name of the player. *)

val get_atk : t -> int
(** Retrieves the attack stat of a player. *)

(* 
 ===================================
  Health functions 
 =================================== 
*)

val get_hp : t -> int
(** Retrieves the HP of a player. *)

val add_hp : int -> t -> (unit, string) result
(** [add_hp num player] adds that number of HP to the player's HP stat. Works
    with negative integers, and allows negative HP. Only allows for modification
    of positive HP. *)

val check_alive : t -> bool
(** [check_alive player] checks if the player's HP is positive. Returns [true]
    if it is.*)

(* 
 ===================================
  Gold functions 
 =================================== 
*)
val get_gold : t -> int
(** Retrieves the number of gold the player has. *)

val add_gold : int -> t -> (unit, string) result
(** [add_gold num player] adds that number of gold to the player's gold stat.
    Works with negative integers. Returns an Error if such modification would
    result in a negative gold balance. *)

(*
 ===================================
  Deck functions 
 =================================== 
*)

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

(*
 ===================================
  Goods functions 
 =================================== 
*)

val get_goods : t -> (Goods.t * int) array
(** Retrieves the player's goods inventory. Each entry contains the good and the
    count of the good. Does not contain empty inventory slots. *)

val get_goods_size : t -> int
(** Retrieves the max size of the player's goods inventory. *)

val add_good : Goods.t -> int -> t -> (unit, string) result
(** [add_good good count player] adds that number of goods to a player's
    inventory and returns a new player when done. Returns an Error if the count
    is negative, or if the player has no more inventory slots. *)

val remove_good_amount : Goods.t -> int -> t -> (unit, string) result
(** [remove_good_amount good count player] removes a number of goods from a
    player's inventory. *)

val remove_good : Goods.t -> t -> (int, string) result
(** [remove_good good player] removes all of the goods from the player's
    inventory with that associated name. Returns the number of goods removed
    from the player if successful. *)
