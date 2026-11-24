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

(** [add_starting_cards player] adds ten starting cards to [player]'s deck. *)
let add_starting_cards player rng =
  let card = Cards.(generate_card Common rng) in
  for _ = 1 to 10 do
    match Player.add_card card player with
    | Ok () -> ()
    | Error message -> failwith message
  done

(** [display_combat combat] displays the current combat status and any defeated
    enemies. *)
let display_combat combat =
  let player = Combat.get_player combat in
  let enemies = Combat.get_enemies combat in
  let hand = Combat.get_hand combat in
  Display.print_combat_status player enemies hand (goods_value player)
    (Combat.get_cards_played combat)
    Combat.max_cards_per_turn;
  List.iter
    (fun enemy ->
      if not (Enemies.check_alive enemy) then Display.print_enemy_defeated enemy)
    enemies

(** [run_shop rng title player] runs a shop encounter and returns the player
    after the player leaves the shop. *)
let run_shop rng title player =
  Display.print_section title;
  let initial_state = Shop.init_shop rng player in
  let rec shop_loop shop_state =
    let current_status = Shop.check_shop_status shop_state in
    match current_status with
    | Shop.Leaving -> shop_state.Shop.player
    | Shop.Buying | Shop.Selling ->
        let items = Shop.get_all_data shop_state.Shop.shop in
        let item_count = List.length items in
        Display.print_shop shop_state.Shop.player items;
        Display.print_shop_inventory shop_state.Shop.player;
        let mode =
          match current_status with
          | Shop.Buying -> "Buying"
          | Shop.Selling -> "Selling"
          | Shop.Leaving -> "Leaving"
        in
        Display.print_shop_menu mode item_count;

        let choice = read_line () |> String.trim in
        let input =
          match int_of_string_opt choice with
          | Some number when number >= 1 && number <= item_count ->
              Some (number - 1)
          | Some number when number = item_count + 1 -> Some item_count
          | Some number when number = item_count + 2 -> Some (item_count + 1)
          | _ -> None
        in

        let updated_state, result = Shop.run_shop shop_state input in
        (match result with
        | Shop.Complete -> Display.print_shop_message "Action completed."
        | Shop.Empty_slot -> Display.print_shop_message "That slot is empty."
        | Shop.Not_enough_gold ->
            Display.print_shop_message "You don't have enough gold."
        | Shop.Not_enough_good ->
            Display.print_shop_message "You don't have that good to sell."
        | Shop.Not_sellable ->
            Display.print_shop_message "Cards cannot be sold."
        | Shop.Invalid_action ->
            Display.print_shop_message "Invalid choice. Try again.");
        shop_loop updated_state
  in
  shop_loop initial_state

(** [run_combat rng player] runs a combat encounter and returns the player after
    combat ends. *)
let run_combat rng player =
  Display.print_section "COMBAT";
  let enemies = Enemies.init_enemies rng 1 in
  let combat = Combat.init_combat rng player enemies in
  let rec combat_loop () =
    display_combat combat;
    if not (Combat.is_over combat) then (
      Display.print_message
        "Choose a card number to play, or press Enter to continue/end your \
         turn:";
      let input = read_line () |> String.trim in
      let card_index = int_of_string_opt input in
      Combat.run_combat rng combat card_index;
      combat_loop ())
  in
  combat_loop ();
  Display.print_section "COMBAT OVER";
  let updated_player = Combat.get_player combat in
  if Player.check_alive updated_player then
    List.iter
      (fun enemy ->
        if not (Enemies.check_alive enemy) then
          let reward = Enemies.get_gold_drop rng enemy in
          match Player.add_gold reward updated_player with
          | Ok () -> Display.print_reward reward
          | Error message -> Display.print_message message)
      enemies
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
    completed or the player is defeated. *)
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
  let player = Player.init_player name 100 5 100 10 10 in
  add_starting_cards player rng;
  display_stats player;
  let player_after_shop = run_shop rng "STARTING SHOP" player in
  let state_after_shop = { stage = 1; player = player_after_shop; rng } in
  let state_after_fight = first_fight state_after_shop in
  finish_game state_after_fight.player
