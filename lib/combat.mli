(** Handles turn-based interactions between the player, enemies, and cards *)

type t
(** The state of a combat encounter. *)

val init_combat : Random.State.t -> Player.t -> Enemies.t -> t
(** [init_combat rand_state player enemy] initializes a combat encounter between
    [player] and [enemy]. *)

val run_combat : Player.t -> Player.t
(** [run_combat player] runs a combat encounter and returns the updated
    player. *)

(* 
 ===================================
  State functions 
 =================================== 
*)

val get_player : t -> Player.t
(** Retrieves the player in the combat encounter. *)

val get_enemy : t -> Enemies.t
(** Retrieves the enemy in the combat encounter. *)

val get_hand : t -> Cards.t list
(** Retrieves the cards currently in the player's hand. *)

val is_over : t -> bool
(** [is_over state] checks if the combat encounter has ended. *)

(* 
 ===================================
  Turn functions 
 =================================== 
*)

val play_card : Cards.t -> t -> (unit, string) result
(** [play_card card state] plays [card] during the player's turn. Returns an
    Error if the card cannot be played. *)

val end_turn : Random.State.t -> t -> unit
(** [end_turn rand_state state] ends the player's turn and executes the enemy's
    turn. *)