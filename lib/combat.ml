type t = unit

(** [init_combat rand_state player enemy] initializes a combat encounter between
    [player] and [enemy]. *)
let init_combat = failwith "Unimplemented"

(** [run_combat player] runs a combat encounter and returns the updated player.
*)
let run_combat = failwith "Unimplemented"

(* ============================================================================
   State functions
   ============================================================================ *)

(** Retrieves the player in the combat encounter. *)
let get_player = failwith "Unimplemented"

(** Retrieves the enemy in the combat encounter. *)
let get_enemy = failwith "Unimplemented"

(** Retrieves the cards currently in the player's hand. *)
let get_hand = failwith "Unimplemented"

(** [is_over state] checks if the combat encounter has ended. *)
let is_over = failwith "Unimplemented"

(* ============================================================================
   Turn functions
   ============================================================================ *)

(** [play_card card state] plays [card] during the player's turn. Returns an
    Error if the card cannot be played. *)
let play_card = failwith "Unimplemented"

(** [end_turn rand_state state] ends the player's turn and executes the enemy's
    turn. *)
let end_turn = failwith "Unimplemented"
