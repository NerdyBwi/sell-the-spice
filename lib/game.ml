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
let starting_hp = 100

(* Display the player's current stats using Player. *)
let display_stats player =
  Printf.printf "\nHealth: %d/%d\n"
    (Player.get_hp player) starting_hp;
  Printf.printf "Damage: %d\n" (Player.get_atk player);
  Printf.printf "Gold: %d\n" (Player.get_gold player);
  Printf.printf "Goods value: %d\n"
    (Goods.inventory_value (Player.get_goods player))

(* Placeholder for Shop. *)
let run_shop title player =
  Printf.printf "\n========== %s ==========\n" title;
  print_endline "PENDING";
  player

(* Placeholder for Combat. *)
let run_combat player =
  print_endline "\n========== COMBAT ==========";
  print_endline "PENDING";
  player

(* Randomly select a shop (30%) or fight (70%). *)
let choose_encounter () =
  if Random.int 100 < 30 then Shop
  else Fight

(* Add a random reward of 10-30 gold after a victory. *)
let reward_player player =
  let reward = 10 + Random.int 21 in
  Printf.printf "\nYou earned %d gold!\n" reward;
  match Player.add_gold reward player with
  | Ok () -> player
  | Error message ->
      Printf.printf "Could not add reward: %s\n" message;
      player

(* Guaranteed first fight after the starting shop. *)
let first_fight state =
  print_endline "\n========== FIRST FIGHT ==========";
  let updated_player = run_combat state.player in
  { state with player = updated_player }

(* Execute the randomly selected encounter for a stage. *)
let execute_stage state =
  Printf.printf "\n========== STAGE %d / %d ==========\n"
    state.stage max_stages;
  match choose_encounter () with
  | Fight ->
      let updated_player = run_combat state.player in
      { state with player = updated_player }
  | Shop ->
      let updated_player = run_shop "SHOP" state.player in
      { state with player = updated_player }

(* Calculate the score from gold and remaining goods. *)
let calculate_score player =
  Player.get_gold player
  + Goods.inventory_value (Player.get_goods player)

(* Final selling phase. *)
let sell_all_goods player =
  print_endline "\n========== FINAL SELLING PHASE ==========";
  let goods_value =
    Goods.inventory_value (Player.get_goods player)
  in
  Printf.printf "Your goods are worth %d gold.\n" goods_value;
  Printf.printf "Goods sold for %d gold!\n" goods_value;
  player

(* Display the final report. *)
let finish_game player =
  let final_player = sell_all_goods player in
  print_endline "\n========== FINAL REPORT ==========";
  if Player.check_alive final_player then
    print_endline "Congratulations! You completed the game!"
  else
    print_endline "You were defeated!";
  Printf.printf "\nFinal health: %d/%d\n"
    (Player.get_hp final_player) starting_hp;
  Printf.printf "Final damage: %d\n"
    (Player.get_atk final_player);
  Printf.printf "Final gold: %d\n"
    (Player.get_gold final_player);
  let score = calculate_score final_player in
  print_endline "\n================================";
  Printf.printf "FINAL SCORE: %d\n" score;
  print_endline "================================";
  print_endline "\nThanks for playing Sell the Spice!"

(* Continue through the randomized stages unless the player dies. *)
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

(* Initialize the game and preserve the original progression. *)
let start_game seed =
  Random.init seed;
  print_endline "================================";
  print_endline "         SELL THE SPICE";
  print_endline "================================";
  print_endline "\nWelcome to Sell the Spice!";
  let player =
    Player.init_player "Merchant" 100 15 100 10 10
  in
  display_stats player;

  (* 1. Guaranteed starting shop. *)
  let state_after_shop =
    run_shop "STARTING SHOP" player
  in
  let state_after_shop = {
    stage = 1;
    player = state_after_shop;
  } in

  (* 2. Guaranteed first fight. *)
  let state_after_fight = first_fight state_after_shop in

  (* 3. Ten randomized stages. *)
  if Player.check_alive state_after_fight.player then
    game_loop state_after_fight
  else
    finish_game state_after_fight.player
