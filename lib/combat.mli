(** Handles turn-based interactions between the player, enemies, and cards *)

type t
(** The state of a combat encounter. *)

val init_combat : Random.State.t -> Player.t -> Enemies.t list -> t
(** [init_combat rng player enemies] initializes a combat state between [player]
    and [enemies]. *)

val run_combat : Random.State.t -> t -> int option -> unit
(** [run_combat rng state input] advances the combat phase by modifying [state]
    when given an [input] action corresponding to the card in the player's hand.
    [None] inputs are valid inputs for initiating enemy turns and otherwise do
    nothing. *)

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

val max_cards_per_turn : int
(** Retrieves how many cards can been played in any turn. *)

val is_over : t -> bool
(** [is_over state] checks if the combat encounter has ended. *)

(* ============================================================================
   Turn functions
   ============================================================================ *)

val play_card : int -> t -> (unit, string) result
(** [play_card input state] plays the card associated with [input] index from
    the player's hand. Returns an Error if the card cannot be played or if the
    input is invalid. *)

val end_turn : Random.State.t -> t -> unit
(** [end_turn rand_state state] ends the player's turn and executes the enemy's
    turn. *)
