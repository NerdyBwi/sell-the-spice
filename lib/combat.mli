(** Handles turn-based interactions between the player, enemies, and cards *)

type t
(** The state of a combat encounter. *)

val init_combat : Random.State.t -> Player.t -> Enemies.t list -> t
(** [init_combat rng player enemies] initializes a combat encounter between
    [player] and [enemies]. *)

val run_combat : Random.State.t -> Cards.t -> t -> unit
(** [run_combat rng card state] plays [card] in [state], increments
    [cards_played], and executes the enemies' turn once three cards have been
    played if combat is still ongoing. *)

(* ============================================================================
   State functions
   ============================================================================ *)

val get_player : t -> Player.t
(** Retrieves the player in the combat encounter. *)

val get_enemies : t -> Enemies.t list
(** Retrieves the enemies in the combat encounter. *)

val get_hand : t -> Cards.t list
(** Retrieves the cards currently in the player's hand. *)

val get_block : t -> int
(** Retrieves the player's current temporary block. *)

val get_turn : t -> int
(** Retrieves the current turn number. *)

val get_cards_played : t -> int
(** Retrieves how many cards have been played on the current turn. *)

val is_over : t -> bool
(** [is_over state] checks if the combat encounter has ended. *)

(* ============================================================================
   Turn functions
   ============================================================================ *)

val play_card : Cards.t -> t -> (unit, string) result
(** [play_card card state] plays [card] during the player's turn. Returns an
    Error if the card cannot be played. *)

val end_turn : Random.State.t -> t -> unit
(** [end_turn rand_state state] ends the player's turn and executes the enemy's
    turn. *)
