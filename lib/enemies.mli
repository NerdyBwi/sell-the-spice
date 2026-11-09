(** Holds the enemy representation and the methods for creating and modifying
    them. *)

type t
(** One enemy instance in combat. *)

type action =
  (* We can decide to add on more actions *)
  | Attack of int
  | Defend of int
  | Pass
      (** [action] represents the intended move an enemy will perform on its
          turn. *)

(* ============================================================================
   Construction functions
   ============================================================================ *)

val init_enemy : Random.State.t -> int -> t
(** [init_enemy rng round] chooses one kind of enemy randomly using [rng] and
    initializes its stats scaled by [round]. *)

val make_enemy : string -> int -> int -> int -> t
(** [make_enemy name hp atk gold_drop] creates a custom enemy with [name],
    starting [hp], base [atk], and base [gold_drop] for deterministic testing.
*)

(* ============================================================================
   State functions
   ============================================================================ *)

val to_string : t -> string
(** [to_string enemy] is a summary string of [enemy]'s name, HP, attack, and
    current intent for terminal display. *)

val get_name : t -> string
(** [get_name enemy] is the display name of [enemy]. *)

val get_hp : t -> int
(** [get_hp enemy] is the current health points of [enemy]. *)

val get_max_hp : t -> int
(** [get_max_hp enemy] is the maximum health points of [enemy]. *)

val get_atk : t -> int
(** [get_atk enemy] is the current attack stat of [enemy]. *)

val get_block : t -> int
(** [get_block enemy] is the current temporary block/defense of [enemy]. *)

val check_alive : t -> bool
(** [check_alive enemy] is [true] if [enemy] has positive HP *)

val add_hp : int -> t -> (unit, string) result
(** [add_hp delta enemy] adds [delta] (positive for healing, negative for
    damage) to [enemy]'s HP. Returns [Error msg] if [enemy] is not alive. *)

val add_atk : int -> t -> unit
(** [add_atk delta enemy] modifies [enemy]'s attack stat by [delta]. *)

val set_block : int -> t -> unit
(** [set_block amount enemy] sets [enemy]'s temporary defense/block to [amount].
*)

(* ============================================================================
   Combat functions
   ============================================================================ *)

val get_intent : t -> action
(** [get_intent enemy] is the action [enemy] currently plans to take at the end
    of the turn. *)

val choose_next_intent : Random.State.t -> t -> action
(** [choose_next_intent rng enemy] selects, updates, and returns the next
    planned [action] for [enemy] using [rng]. *)

val intent_to_string : t -> string
(** [intent_to_string enemy] is a human-readable description of [enemy]'s
    current planned action (e.g., ["Will deal 12 damage"]). *)

val scale_turn : int -> t -> unit
(** [scale_turn turn enemy] scales [enemy]'s stats (such as attack damage) based
    on the current combat [turn] number. *)

val get_gold_drop : Random.State.t -> t -> int
(** [get_gold_drop rng enemy] is the amount of gold dropped when [enemy] is
    defeated. *)
