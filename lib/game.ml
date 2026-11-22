(* Game progression and coordination between modules. *)
type game_state = {
  stage : int;
  player : Player.t;
}

(* Each randomized stage leads to either a fight or a shop. *)
type encounter =
  | Fight
  | Shop

let max_stages = 10

(** [goods_value player] calculates the total value of the goods currently held
    by [player]. *)
let goods_value player =
  Player.get_goods player
  |> Array.fold_left
       (fun total (good, amount) -> total + (Goods.value good * amount))
       0

(** [display_stats player] displays the player's statistics. *)
let display_stats player =
  Display.print_player_stats player (goods_value player)

(** [run_shop rand_state title player] initializes and displays a shop
    encounter. Buying and selling remain delegated to the Shop implementation.
*)
let run_shop rand_state title player =
  let _shop = Shop.init_shop rand_state in
  Display.print_section title;
  Display.print_message "Shop initialized.";
  player

(** [run_combat rand_state stage player] initializes an enemy and combat,
    displays the player and first enemy, and returns the updated player. *)
let run_combat rand_state stage player =
  let enemy = Enemies.init_enemy rand_state stage in
  Display.print_combat player [ enemy ];
  ignore (Combat.init_combat rand_state player enemy);
  Combat.run_combat player

(** [choose_encounter rand_state] randomly selects a shop (30%) or fight (70%)
    using the game's seeded random state. *)
let choose_encounter rand_state =
  if Random.State.int rand_state 100 < 30 then Shop else Fight

(** [reward_player rand_state player] adds a random reward of 10-30 gold. *)
let reward_player rand_state player =
  let reward = 10 + Random.State.int rand_state 21 in
  Display.print_reward reward;
  match Player.add_gold reward player with
  | Ok () -> player
  | Error message ->
      Display.print_message ("Could not add reward: " ^ message);
      player

(** [first_fight rand_state state] executes the guaranteed first fight. *)
let first_fight rand_state state =
  Display.print_section "FIRST FIGHT";
  let updated_player = run_combat rand_state state.stage state.player in
  { state with player = updated_player }

(** [execute_stage rand_state state] executes the selected encounter. *)
let execute_stage rand_state state =
  Display.print_stage state.stage max_stages;
  match choose_encounter rand_state with
  | Fight ->
      let updated_player = run_combat rand_state state.stage state.player in
      { state with player = updated_player }
  | Shop ->
      let updated_player = run_shop rand_state "SHOP" state.player in
      { state with player = updated_player }

(** [calculate_score player] calculates the final score. *)
let calculate_score player = Player.get_gold player + goods_value player

(** [sell_all_goods player] displays the final selling phase. *)
let sell_all_goods player =
  Display.print_selling_phase (goods_value player);
  player

(** [finish_game player] displays the final report. *)
let finish_game player =
  let final_player = sell_all_goods player in
  let score = calculate_score final_player in
  Display.print_final_report final_player score;
  Display.print_goodbye ()

(** [game_loop rand_state state] continues until all stages are completed or the
    player is defeated. *)
let rec game_loop rand_state state =
  if state.stage > max_stages || not (Player.check_alive state.player) then
    finish_game state.player
  else
    let updated_state = execute_stage rand_state state in
    if Player.check_alive updated_state.player then
      game_loop rand_state { updated_state with stage = state.stage + 1 }
    else finish_game updated_state.player

(** [start_game seed player_name] initializes and starts a game using [seed] and
    the supplied [player_name]. *)
let start_game seed player_name =
  let rand_state = Random.State.make [| seed |] in
  Display.print_banner ();
  let player = Player.init_player player_name 100 15 100 10 10 in
  display_stats player;

  (* Guaranteed starting shop. *)
  let player_after_shop = run_shop rand_state "STARTING SHOP" player in
  let state_after_shop = { stage = 1; player = player_after_shop } in

  (* Guaranteed first fight. *)
  let state_after_fight = first_fight rand_state state_after_shop in

  (* End the game after the first fight. *)
  finish_game state_after_fight.player
