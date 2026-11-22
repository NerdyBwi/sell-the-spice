(** Handles turn-based interactions between the player, enemies, and cards *)

type status =
  | Ongoing
  | Finished

type t = {
  player : Player.t;
  mutable block : int;
  mutable enemies : Enemies.t list;
  mutable status : status;
  mutable turn : int;
  mutable cards_played : int
}
let max_cards_per_turn = 3

(** [init_combat rng player enemies] initializes a combat encounter between
    [player] and [enemies]. *)
let init_combat rng (player : Player.t)  (enemy : Enemies.t list) = 
  { player = player;
    block = 0;
    enemies = enemies;
    status = Ongoing;
    turn = 1;
    cards_played = 0
}

(** float * int operator *)
let ( *.* ) f i = f *. float_of_int i

(** int * float operator *)
let ( **. ) i f = float_of_int i *. f

(* ============================================================================
   State functions
   ============================================================================ *)

(** Retrieves the player in the combat encounter. *)
let get_player s = s.player

(** Retrieves the enemy in the combat encounter. *)
let get_enemies s = s.enemies

(** Retrieves the cards currently in the player's hand. *)
let get_hand s = []

(** [get_cards_played state] retrieves how many cards have been played on the
    current turn. *)
let get_cards_played state = state.cards_played

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

(** [deal_damage_to_enemy damage target] applies [damage] to [target], absorbing
    damage with [target]'s block before reducing HP. *)
let deal_damage_to_enemy damage target =
  let damage = max 0 damage in
  let block = Enemies.get_block target in
  let absorbed = min block damage in
  Enemies.set_block (block - absorbed) target;
  let remaining = damage - absorbed in
  if remaining > 0 then Enemies.add_hp (-remaining) target else Ok ()

(** [deal_damage_to_player damage state] applies [damage] to the player in
    [state], absorbing damage with [state.block] before reducing HP. *)
let deal_damage_to_player damage state =
  let damage = max 0 damage in
  let absorbed = min state.block damage in
  state.block <- state.block - absorbed;
  let remaining = damage - absorbed in
  if remaining > 0 && Player.check_alive state.player then
    (Player.add_hp (-remaining) state.player)

(** [execute_enemy_turn enemy state] resolves [enemy]'s planned action. *)
let execute_enemy_turn enemy state =
  if Enemies.check_alive enemy then begin
    Enemies.set_block 0 enemy;
    match Enemies.get_intent enemy with
    | Enemies.Attack damage -> deal_damage_to_player damage state
    | Enemies.Defend amount -> Enemies.set_block amount enemy
    | Enemies.Pass -> ()
  end

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

(** [end_turn rng state] ends the player's turn and executes the enemies' turn. *)
let end_turn (rng : Random.State.t) (state : t) =
  if not (is_over state) then begin
    List.iter (fun enemy -> execute_enemy_turn enemy state) state.enemies;
    if (not (Player.check_alive state.player)) || find_enemy state.enemies = None
    then state.status <- Finished
    else begin
      state.block <- 0;
      state.cards_played <- 0;
      state.turn <- state.turn + 1;
      List.iter
        (fun enemy ->
          if Enemies.check_alive enemy then begin
            Enemies.scale_turn state.turn enemy;
            (Enemies.choose_next_intent rng enemy)
          end)
        state.enemies
    end
  end

(** [run_combat rng card state] plays [card] in [state], increments
    [cards_played], and executes the enemies' turn once three cards have been
    played if combat is still ongoing. *)
let run_combat (rng : Random.State.t) (card : Cards.t) (state : t) =
  if not (is_over state) then
    match play_card card state with
    | Error _ -> ()
    | Ok () ->
        state.cards_played <- state.cards_played + 1;
        if (not (is_over state)) && state.cards_played >= max_cards_per_turn
        then end_turn rng state
