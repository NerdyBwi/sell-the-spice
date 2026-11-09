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

(** [init_enemy rng round] chooses one kind of enemy randomly using [rng] and
    initializes its stats scaled by [round]. *)
let init_enemy = failwith "Unimplemented"

(** [make_enemy name hp atk gold_drop] creates a custom enemy with [name],
    starting [hp], base [atk], and base [gold_drop] for deterministic testing.
*)
let make_enemy = failwith "Unimplemented"

(* ============================================================================
   State functions
   ============================================================================ *)

(** [to_string enemy] is a summary string of [enemy]'s name, HP, attack, and
    current intent for terminal display. *)
let to_string = failwith "Unimplemented"

(** [get_name enemy] is the display name of [enemy]. *)
let get_name = failwith "Unimplemented"

(** [get_hp enemy] is the current health points of [enemy]. *)
let get_hp = failwith "Unimplemented"

(** [get_max_hp enemy] is the maximum health points of [enemy]. *)
let get_max_hp = failwith "Unimplemented"

(** [get_atk enemy] is the current attack stat of [enemy]. *)
let get_atk = failwith "Unimplemented"

(** [get_block enemy] is the current temporary block/defense of [enemy]. *)
let get_block = failwith "Unimplemented"

(** [check_alive enemy] is [true] if [enemy] has positive HP *)
let check_alive = failwith "Unimplemented"

(** [add_hp delta enemy] adds [delta] (positive for healing, negative for
    damage) to [enemy]'s HP. Returns [Error msg] if [enemy] is not alive. *)
let add_hp = failwith "Unimplemented"

(** [add_atk delta enemy] modifies [enemy]'s attack stat by [delta]. *)
let add_atk = failwith "Unimplemented"

(** [set_block amount enemy] sets [enemy]'s temporary defense/block to [amount].
*)
let set_block = failwith "Unimplemented"

(* ============================================================================
   Combat functions
   ============================================================================ *)

(** [get_intent enemy] is the action [enemy] currently plans to take at the end
    of the turn. *)
let get_intent = failwith "Unimplemented"

(** [choose_next_intent rng enemy] selects, updates, and returns the next
    planned [action] for [enemy] using [rng]. *)
let choose_next_intent = failwith "Unimplemented"

(** [intent_to_string enemy] is a human-readable description of [enemy]'s
    current planned action (e.g., ["Will deal 12 damage"]). *)
let intent_to_string = failwith "Unimplemented"

(** [scale_turn turn enemy] scales [enemy]'s stats (such as attack damage) based
    on the current combat [turn] number. *)
let scale_turn = failwith "Unimplemented"

(** [get_gold_drop rng enemy] is the amount of gold dropped when [enemy] is
    defeated. *)
let get_gold_drop = failwith "Unimplemented"
