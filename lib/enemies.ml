(** Holds the enemy representation and the methods for creating and modifying
    them. *)

type action =
  (* We can decide to add on more actions *)
  | Attack of int
  | Defend of int
  | Pass
      (** [action] represents the intended move an enemy will perform on its
          turn. *)

type t = {
  name : string;
  mutable hp : int;
  max_hp : int;
  mutable atk : int;
  def : int; (* this value represents how much an enemy typically defends by. *)
  mutable block : int;
  gold_drop : int;
  mutable intent : action;
}
(**Contains data representing a single enemy.*)

(** float * int operator *)
let ( *.* ) f i = f *. float_of_int i

(** int * float operator *)
let ( **. ) i f = float_of_int i *. f

(* ============================================================================
   Construction functions
   ============================================================================ *)

(* Constants that represent how fast an enemy scales off of round number. *)
let fast_s = 1.15
let medium_s = 1.05
let slow_s = 1.025

(**Contains the pool of enemies. Entry [0] corresponds to common enemies, Entry
   [2] corresponds to "elite" enemies, Entry [3] corresponds to "boss" enemies.

   Each entry's enemy is in the form of:
   [(name, [hp; atk; def; gold_drop], scale_factor, count)])*)
let enemy_pool =
  [|
    [|
      ("Ghoul", [ 25; 5; 5; 5 ], fast_s, 1);
      ("Bandit", [ 35; 10; 2; 10 ], fast_s, 1);
    |];
    [| ("jim", [ 67420; 67420; 67420; 67 ], slow_s, 1) |];
    (* joke enemies not intended to remain in the final game *)
    [| ("jim", [ 67420; 67420; 67420; 99 ], slow_s, 1) |];
  |]

(** [make_enemy name hp atk def gold_drop] creates a custom enemy with [name],
    starting [hp], base [atk], base [def], and a base [gold_drop] for
    deterministic testing. *)
let make_enemy name hp atk def gold_drop =
  { name; hp; max_hp = hp; atk; def; block = 0; gold_drop; intent = Pass }

(** [init_enemies rng round] chooses one kind of enemy randomly using [rng] and
    initializes its stats scaled by [round]. *)
let init_enemies rng round =
  (* randomness isn't implemented yet, so it currently just pulls the ghoul from
     the pool. *)
  let name, stats, scale, count = enemy_pool.(0).(0) in
  let helper_tup_of_lst lst =
    (* extracts the stats out of the list part of the enemy data *)
    match lst with
    | [ hp; atk; def; gd ] -> (hp, atk, def, gd)
    | _ -> failwith ("Malformed enemy data error for: " ^ name)
  in
  let hp, atk, def, gd =
    stats |> List.map (fun x -> int_of_float (x **. scale)) |> helper_tup_of_lst
  in

  let rec helper_init_enemy acc count =
    if count > 0 then
      helper_init_enemy (make_enemy name hp atk def gd :: acc) (count - 1)
    else acc
  in
  helper_init_enemy [] count

(* ============================================================================
   State functions
   ============================================================================ *)

(** [get_name enemy] is the display name of [enemy]. *)
let get_name e = e.name

(** [get_hp enemy] is the current health points of [enemy]. *)
let get_hp e = e.hp

(** [get_max_hp enemy] is the maximum health points of [enemy]. *)
let get_max_hp e = e.max_hp

(** [get_atk enemy] is the current attack stat of [enemy]. *)
let get_atk e = e.atk

(** [get_block enemy] is the current temporary block/defense of [enemy]. *)
let get_block e = e.block

(** [check_alive enemy] is [true] if [enemy] has positive HP *)
let check_alive e = e.hp > 0

(** [add_hp delta enemy] adds [delta] (positive for healing, negative for
    damage) to [enemy]'s HP. Returns [Error msg] if [enemy] is not alive. *)
let add_hp d e =
  if check_alive e then Ok (e.hp <- min (e.hp + d) e.max_hp)
  else
    Error
      (Printf.sprintf
         "Attempted to add [%d] to [HP: %d]; failed due to enemy not being \
          alive."
         d e.hp)

(** [add_atk delta enemy] modifies [enemy]'s attack stat by [delta]. *)
let add_atk d e =
  let outcome = e.atk + d in
  if outcome > 0 then Ok (e.atk <- outcome)
  else
    Error
      (Printf.sprintf
         "Attempted to add [%d] to [Atk: %d]; failed due to negative atk \
          outcome."
         d e.atk)

(** [set_block amount enemy] sets [enemy]'s temporary block to [amount]. *)
let set_block a e = e.block <- a

(* ============================================================================
   Combat functions
   ============================================================================ *)

(** [get_intent enemy] is the action [enemy] currently plans to take at the end
    of the turn. *)
let get_intent e = e.intent

(** [choose_next_intent rng enemy] selects, updates, and returns the next
    planned [action] for [enemy] using [rng]. *)
let choose_next_intent rng e =
  let roll = Random.State.int rng 10 in
  let next_intent =
    if roll < 6 then Attack e.atk else if roll < 9 then Defend e.def else Pass
  in
  e.intent <- next_intent;
  next_intent

(** [intent_to_string enemy] is a human-readable description of [enemy]'s
    current planned action (e.g., ["Will deal 12 damage"]). *)
let intent_to_string e =
  let i = get_intent e in
  match i with
  | Attack v -> Printf.sprintf "Attack %d" v
  | Defend v -> Printf.sprintf "Block %d" v
  | Pass -> "Pass"

(** [scale_turn turn enemy] scales [enemy]'s stats (such as attack damage) based
    on the current combat [turn] number. *)
let scale_turn turn e =
  if turn > 1 then
    let scaled_atk = int_of_float (medium_s *.* e.atk) in
    e.atk <- max (e.atk + 1) scaled_atk

(** [get_gold_drop rng enemy] is the amount of gold dropped when [enemy] is
    defeated. *)
let get_gold_drop rng e =
  if e.gold_drop <= 0 then 0
  else
    let spread = max 1 (e.gold_drop / 4) in
    let offset = Random.State.int rng ((2 * spread) + 1) - spread in
    max 1 (e.gold_drop + offset)
