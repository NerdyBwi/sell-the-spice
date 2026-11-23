(* Game progression and coordination between modules. *)
type game_state = {
  stage : int;
  player : Player.t;
  rng : Random.State.t;
}

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

(** [display_stats player] displays the player's current statistics. *)
let display_stats player =
  Display.print_player_stats player (goods_value player)

(** [run_shop rng title player] initializes a shop encounter. The current Shop
    interface does not expose its inventory or a way to complete purchases, so
    this remains a placeholder until that interface is expanded. *)
let run_shop _rng title player =
  Display.print_section title;
  Display.print_message
    "The shop interface is not ready yet; shopping is unavailable.";
  player

(** [run_combat rng player] runs a combat encounter and returns the player after
    combat ends. The same combat state is retained for the whole fight. *)
let run_combat rng player =
  Display.print_section "COMBAT";
  let enemy = Enemies.init_enemy rng 1 in
  let combat = Combat.init_combat rng player enemy in
  let rec combat_loop () =
    if Combat.is_over combat then ()
    else (
      Display.print_combat combat;
      Display.print_message
        "Choose a card number to play, or enter e to end your turn.";
      let input = read_line () |> String.trim in
      if String.lowercase_ascii input = "e" then Combat.end_turn rng combat
      else (
        (match int_of_string_opt input with
        | None ->
            Display.print_message "Invalid input. Enter a card number or e."
        | Some index -> (
            let hand = Combat.get_hand combat in
            if index < 1 || index > List.length hand then
              Display.print_message "That card number is not in your hand."
            else
              let card = List.nth hand (index - 1) in
              match Combat.play_card card combat with
              | Ok () -> ()
              | Error message -> Display.print_message message));
        combat_loop ()))
  in
  combat_loop ();
  let updated_player = Combat.get_player combat in
  let defeated_enemy = not (Enemies.check_alive (Combat.get_enemy combat)) in
  if defeated_enemy then (
    Display.print_message "Enemy defeated!";
    let reward = Enemies.get_gold_drop rng (Combat.get_enemy combat) in
    match Player.add_gold reward updated_player with
    | Ok () -> Display.print_reward reward
    | Error message -> Display.print_message ("Could not add reward: " ^ message))
  else Display.print_message "You were defeated.";
  updated_player

(** [choose_encounter rng] randomly selects a shop (30%) or fight (70%) using
    [rng]. *)
let choose_encounter rng = if Random.State.int rng 100 < 30 then Shop else Fight

(** [reward_player rng player] adds a random reward of 10-30 gold. *)
let reward_player rng player =
  let reward = 10 + Random.State.int rng 21 in
  Display.print_reward reward;
  match Player.add_gold reward player with
  | Ok () -> player
  | Error message ->
      Display.print_message ("Could not add reward: " ^ message);
      player

(** [first_fight state] executes the guaranteed first fight. *)
let first_fight state =
  Display.print_section "FIRST FIGHT";
  let updated_player = run_combat state.rng state.player in
  { state with player = updated_player }

(** [execute_stage state] executes the selected encounter. *)
let execute_stage state =
  Display.print_stage state.stage max_stages;
  match choose_encounter state.rng with
  | Fight ->
      let updated_player = run_combat state.rng state.player in
      { state with player = updated_player }
  | Shop ->
      let updated_player = run_shop state.rng "SHOP" state.player in
      { state with player = updated_player }

(** [calculate_score player] calculates the final score. *)
let calculate_score player = Player.get_gold player + goods_value player

(** [sell_all_goods player] displays the final selling phase. Actual selling
    requires a player choice and a completed shop/selling interface; this
    function does not claim that goods have been sold. *)
let sell_all_goods player =
  Display.print_selling_phase (goods_value player);
  player

(** [finish_game player] displays the final report. *)
let finish_game player =
  let final_player = sell_all_goods player in
  let score = calculate_score final_player in
  Display.print_final_report final_player score;
  Display.print_goodbye ()

(** [game_loop state] continues through later stages until all stages are
    completed or the player is defeated. This is retained for later milestones.
*)
let rec game_loop state =
  if state.stage > max_stages || not (Player.check_alive state.player) then
    finish_game state.player
  else
    let updated_state = execute_stage state in
    if Player.check_alive updated_state.player then
      game_loop { updated_state with stage = state.stage + 1 }
    else finish_game updated_state.player

(** [start_game seed name] initializes the player and runs the MS2 demo: the
    starting shop, the first battle, and the final report. *)
let start_game seed name =
  let rng = Random.State.make [| seed |] in
  Display.print_banner ();
  let player = Player.init_player name 100 15 100 10 10 in
  display_stats player;
  let player_after_shop = run_shop rng "STARTING SHOP" player in
  let state_after_shop = { stage = 1; player = player_after_shop; rng } in
  let state_after_fight = first_fight state_after_shop in
  finish_game state_after_fight.player
