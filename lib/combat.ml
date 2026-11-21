type status =
  | Ongoing
  | Finished

type t = {
  player : Player.t;
  mutable block : int;
  mutable enemies : Enemies.t list;
  mutable status : status;
  mutable turn : int;
}

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
let get_player s = s.player

(** Retrieves the enemy in the combat encounter. *)
let get_enemies s = s.enemies

(** Retrieves the cards currently in the player's hand. *)
let get_hand s = []

(** [is_over state] checks if the combat encounter has ended. *)
let is_over s =
  match s.status with
  | Ongoing -> false
  | Finished -> true

(* ============================================================================
   Turn functions
   ============================================================================ *)

(** Helper function [find_enemy enemies] finds the first enemy in a list of
    enemies that is not dead and returns it as an option.*)
let find_enemy lst =
  List.fold_left
    (fun acc e -> if Enemies.check_alive e then Some e else acc)
    None lst

(** [play_card card state] plays [card] during the player's turn. Returns an
    Error if the card cannot be played. *)
let play_card (c : Cards.t) (s : t) =
  let open Cards in
  let keyword, value = get_card_effect c in
  match keyword with
  | Attack -> (
      match find_enemy s.enemies with
      | None -> Error "No enemies available that can be targetted!"
      | Some target ->
          let damage = Player.get_atk (get_player s) * value in
          Enemies.add_hp (-1 * damage) target)
  | Defend -> Ok (s.block <- s.block + value)
  | Heal -> Player.add_hp value (get_player s)
  | Draw -> Error "Unimplemented card type: Draw"
  | Buff -> Error "Unimplmented card type: Buff"

(** [end_turn rand_state state] ends the player's turn and executes the enemy's
    turn. *)
let end_turn = failwith "Unimplemented"
