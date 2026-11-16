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

(** [goods_value player] calculates the total value of the
    goods currently held by the player. *)
let goods_value player =
  Player.get_goods player
  |> Array.fold_left
       (fun total (good, amount) ->
         total + (Goods.value good * amount))
       0

(** [display_stats player] displays the player's statistics. *)
let display_stats player =
  Display.print_player_stats player (goods_value player)

(** [run_shop title player] runs a shop encounter.
    Placeholder. *)
let run_shop title player =
  Display.print_section title;
  Display.print_message "Pending.";
  player

(** [run_combat player] runs a combat encounter.
    Placeholder. *)
let run_combat player =
  Display.print_section "COMBAT";
  Display.print_message "Pending.";
  player

(** [choose_encounter ()] randomly selects a shop (30%)
    or fight (70%). *)
let choose_encounter () =
  if Random.int 100 < 30 then Shop
  else Fight

(** [reward_player player] adds a random reward of 10-30 gold. *)
let reward_player player =
  let reward = 10 + Random.int 21 in
  Display.print_reward reward;
  match Player.add_gold reward player with
  | Ok () -> player
  | Error message ->
      Display.print_message
        ("Could not add reward: " ^ message);
      player

(** [first_fight state] executes the guaranteed first fight. *)
let first_fight state =
  Display.print_section "FIRST FIGHT";
  let updated_player = run_combat state.player in
  { state with player = updated_player }

(** [execute_stage state] executes the selected encounter. *)
let execute_stage state =
  Display.print_stage state.stage max_stages;
  match choose_encounter () with
  | Fight ->
      let updated_player = run_combat state.player in
      { state with player = updated_player }
  | Shop ->
      let updated_player = run_shop "SHOP" state.player in
      { state with player = updated_player }

(** [calculate_score player] calculates the final score. *)
let calculate_score player =
  Player.get_gold player + goods_value player

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

(** [game_loop state] continues until all stages are completed
    or the player is defeated. *)
let rec game_loop state =
  if state.stage > max_stages
     || not (Player.check_alive state.player)
  then
    finish_game state.player
  else
    let updated_state = execute_stage state in
    if Player.check_alive updated_state.player then
      game_loop {
        updated_state with
        stage = state.stage + 1
      }
    else
      finish_game updated_state.player

(** [start_game seed] initializes and starts the game. *)
let start_game seed =
  Random.init seed;
  Display.print_banner ();
  let player =
    Player.init_player "Merchant" 100 15 100 10 10
  in
  display_stats player;

  (* Guaranteed starting shop. *)
  let player_after_shop =
    run_shop "STARTING SHOP" player
  in
  let state_after_shop = {
    stage = 1;
    player = player_after_shop;
  } in

  (* Guaranteed first fight. *)
  let state_after_fight =
    first_fight state_after_shop
  in

  (* Ten randomized stages. *)
  if Player.check_alive state_after_fight.player then
    game_loop state_after_fight
  else
    finish_game state_after_fight.player
