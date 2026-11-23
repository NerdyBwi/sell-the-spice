(** [print_banner ()] displays the game's title. *)
let print_banner () =
  print_endline "================================";
  print_endline "         SELL THE SPICE";
  print_endline "================================";
  print_endline "\nWelcome to Sell the Spice!"

(** [print_section title] displays a section heading. *)
let print_section title = Printf.printf "\n========== %s ==========\n" title

(** [print_stage stage total] displays the current stage. *)
let print_stage stage total =
  Printf.printf "\n========== STAGE %d / %d ==========\n" stage total

(** [print_player_stats player goods_value] displays player statistics. *)
let print_player_stats player goods_value =
  Printf.printf "\nHealth: %d/%d\n" (Player.get_hp player)
    (Player.get_max_hp player);
  Printf.printf "Damage: %d\n" (Player.get_atk player);
  Printf.printf "Gold: %d\n" (Player.get_gold player);
  Printf.printf "Goods value: %d\n" goods_value

(** [print_reward amount] displays a gold reward. *)
let print_reward amount = Printf.printf "\nYou earned %d gold!\n" amount

(** [print_message message] displays a general message. *)
let print_message message = print_endline message

(** [print_selling_phase goods_value] displays the selling summary. *)
let print_selling_phase goods_value =
  print_section "FINAL SELLING PHASE";
  Printf.printf "Your goods are worth %d gold.\n" goods_value;
  Printf.printf "Goods sold for %d gold!\n" goods_value

(** [print_final_report player score] displays the final report. *)
let print_final_report player score =
  print_section "FINAL REPORT";
  if Player.check_alive player then
    print_endline "Congratulations! You completed the game!"
  else print_endline "You were defeated!";
  Printf.printf "\nFinal health: %d/%d\n" (Player.get_hp player)
    (Player.get_max_hp player);
  Printf.printf "Final damage: %d\n" (Player.get_atk player);
  Printf.printf "Final gold: %d\n" (Player.get_gold player);
  print_endline "\n================================";
  Printf.printf "FINAL SCORE: %d\n" score;
  print_endline "================================"

(** [print_goodbye ()] displays the closing message. *)
let print_goodbye () = print_endline "\nThanks for playing Sell the Spice!"

(** [print_combat player enemies] displays the player's combat statistics and
    the first enemy in [enemies]. If the list is empty, displays that no enemies
    remain. *)
let print_combat player enemies =
  print_section "COMBAT";
  Printf.printf "Player: %s\n" (Player.get_name player);
  Printf.printf "Health: %d/%d\n" (Player.get_hp player)
    (Player.get_max_hp player);
  Printf.printf "Damage: %d\n" (Player.get_atk player);
  Printf.printf "Gold: %d\n" (Player.get_gold player);
  match enemies with
  | [] -> print_message "No enemies remain."
  | enemy :: _ ->
      Printf.printf "\nEnemy: %s\n" (Enemies.get_name enemy);
      Printf.printf "Enemy health: %d/%d\n" (Enemies.get_hp enemy)
        (Enemies.get_max_hp enemy);
      Printf.printf "Enemy damage: %d\n" (Enemies.get_atk enemy);
      Printf.printf "Enemy intent: %s\n" (Enemies.intent_to_string enemy)
