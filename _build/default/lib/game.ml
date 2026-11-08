(* Track the player's stats, gold, and progress through the stages. *)
type game_state = {
  stage : int;
  health : int;
  max_health : int;
  damage : int;
  defense : int;
  gold : int;
  goods_value : int;
  alive : bool;
}

(* Each randomized stage leads to either a fight or a shop. *)
type encounter =
  | Fight
  | Shop
let max_stages = 10

(* Show the player's current health, combat stats, and money. *)
let display_stats state =
  Printf.printf "\nHealth: %d/%d\n"
    state.health state.max_health;
  Printf.printf "Damage: %d\n" state.damage;
  Printf.printf "Defense: %d\n" state.defense;
  Printf.printf "Gold: %d\n" state.gold;
  Printf.printf "Goods value: %d\n" state.goods_value

(* Keep asking until the player enters one of the listed choices. *)
let rec get_choice prompt options =
  print_endline prompt;
  List.iter
    (fun (_, description) -> print_endline description)
    options;
  print_string "> ";
  match read_line () with
  | choice when List.mem choice (List.map fst options) ->
      choice
  | _ ->
      print_endline "Invalid choice. Try again.";
      get_choice prompt options

(* Use the same menu for the opening shop and shops during later stages. *)
let rec shop_menu title state =
  Printf.printf "\n========== %s ==========\n" title;
  Printf.printf "Available gold: %d\n" state.gold;
  let choice =
    get_choice "What would you like to do?"
      [ ("1", "1. Buy a card");
        ("2", "2. Buy a good");
        ("3", "3. View stats");
        ("4", "4. Leave shop") ]
  in
  match choice with
  | "1" ->
      print_endline
        "Will be implemented later.";
      shop_menu title state
  | "2" ->
      print_endline
        "Will be implemented later.";
      shop_menu title state
  | "3" ->
      display_stats state;
      shop_menu title state
  | "4" ->
      print_endline "Leaving the shop...";
      state
  | _ ->
      state

(* Open the shop before the guaranteed first fight. *)
let starting_shop state =
  shop_menu "STARTING SHOP" state

(* Roll once per stage to choose a shop (30%) or fight (70%). *)
let choose_encounter () =
  if Random.int 100 < 30 then
    Shop
  else
    Fight

(* Subtract defense from incoming damage before updating health. *)
let take_damage state incoming_damage =
  let actual_damage =
    max 0 (incoming_damage - state.defense)
  in
  let new_health =
    max 0 (state.health - actual_damage)
  in
  let updated_state = {
    state with
    health = new_health;
    alive = new_health > 0
  } in
  if not updated_state.alive then
    print_endline "\nYou have been defeated!"
  else
    Printf.printf "\nYou took %d damage!\n" actual_damage;
  updated_state

(* Run a fight against a basic enemy until either side is defeated. *)
let combat state =
  print_endline "\n========== COMBAT ==========";
  print_endline "An enemy approaches!";
  let enemy_health = 30 in
  let enemy_damage = 10 in
  let rec combat_round state enemy_health =
    if not state.alive then
      state
    else (
      Printf.printf "\nYour health: %d/%d\n"
        state.health state.max_health;
      Printf.printf "Enemy health: %d\n" enemy_health;
      let choice =
        get_choice "Choose an action:"
          [ ("1", "1. Attack");
            ("2", "2. View stats") ]
      in
      match choice with
      | "1" ->
          Printf.printf "\nYou deal %d damage!\n"
            state.damage;
          let remaining_enemy_health =
            max 0 (enemy_health - state.damage)
          in
          if remaining_enemy_health = 0 then (
            print_endline "You defeated the enemy!";
            state
          )
          else (
            print_endline "The enemy attacks!";
            let updated_state =
              take_damage state enemy_damage
            in
            combat_round updated_state remaining_enemy_health
          )
      | "2" ->
          display_stats state;
          combat_round state enemy_health
      | _ ->
          state
    )
  in
  combat_round state enemy_health

(* Add a random reward of 10–30 gold after a victory. *)
let reward_player state =
  let reward = 10 + Random.int 21 in
  Printf.printf "\nYou earned %d gold!\n" reward;
  { state with gold = state.gold + reward }

(* Run the required fight immediately after the opening shop. *)
let first_fight state =
  print_endline "\n========== FIRST FIGHT ==========";
  let updated_state = combat state in
  if updated_state.alive then
    reward_player updated_state
  else
    updated_state

(* Run the shop or fight selected for the current stage. *)
let execute_stage state =
  Printf.printf "\n========== STAGE %d / %d ==========\n"
    state.stage max_stages;
  match choose_encounter () with
  | Fight ->
      let updated_state = combat state in
      if updated_state.alive then
        reward_player updated_state
      else
        updated_state
  | Shop ->
      shop_menu "SHOP" state

(* Use the player's final gold as the current score. *)
let calculate_score state =
  state.gold

(* Convert the remaining goods value into gold before scoring. *)
let sell_all_goods state =
  print_endline "\n========== FINAL SELLING PHASE ==========";
  Printf.printf "Your goods are worth %d gold.\n"
    state.goods_value;
  let final_gold = state.gold + state.goods_value in
  Printf.printf "Goods sold for %d gold!\n"
    state.goods_value;
  {
    state with
    gold = final_gold;
    goods_value = 0
  }

(* Print the player's final results after the last stage or defeat. *)
let finish_game state =
  let final_state = sell_all_goods state in
  print_endline "\n========== FINAL REPORT ==========";
  if final_state.alive then
    print_endline "Congratulations! You completed the game!"
  else
    print_endline "You were defeated!";
  Printf.printf "\nFinal health: %d/%d\n"
    final_state.health final_state.max_health;
  Printf.printf "Final damage: %d\n"
    final_state.damage;
  Printf.printf "Final defense: %d\n"
    final_state.defense;
  Printf.printf "Final gold: %d\n"
    final_state.gold;
  let score = calculate_score final_state in
  Printf.printf "\n================================\n";
  Printf.printf "FINAL SCORE: %d\n" score;
  Printf.printf "================================\n";
  print_endline "\nThanks for playing Sell the Spice!"

(* Continue through the 10 randomized stages unless the player dies. *)
let rec game_loop state =
  if state.stage > max_stages || not state.alive then
    finish_game state
  else
    let updated_state = execute_stage state in
    if updated_state.alive then
      game_loop {
        updated_state with
        stage = state.stage + 1
      }
    else
      finish_game updated_state

(* Set starting stats, open the first shop, and begin the stages. *)
let start_game seed =
  Random.init seed;
  print_endline "================================";
  print_endline "         SELL THE SPICE";
  print_endline "================================";
  let initial_state = {
    stage = 1;
    health = 100;
    max_health = 100;
    damage = 15;
    defense = 5;
    gold = 100;
    goods_value = 0;
    alive = true;
  } in
  print_endline "\nWelcome to Sell the Spice!";

  (* 1. Starting shop *)
  let state_after_shop = starting_shop initial_state in

  (* 2. Guaranteed first fight *)
  let state_after_fight = first_fight state_after_shop in

  (* 3. Ten randomized stages *)
  if state_after_fight.alive then
    game_loop state_after_fight
  else
    finish_game state_after_fight
