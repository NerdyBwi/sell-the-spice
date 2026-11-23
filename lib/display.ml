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
  Printf.printf "\nMerchant: %s\n" (Player.get_name player);
  Printf.printf "Health: %d/%d\n" (Player.get_hp player)
    (Player.get_max_hp player);
  Printf.printf "Damage: %d\n" (Player.get_atk player);
  Printf.printf "Gold: %d\n" (Player.get_gold player);
  Printf.printf "Goods value: %d\n" goods_value

(** [print_enemy enemy] displays the enemy's current statistics and intent. *)
let print_enemy enemy =
  Printf.printf "\nEnemy: %s\n" (Enemies.get_name enemy);
  Printf.printf "Health: %d/%d\n" (Enemies.get_hp enemy)
    (Enemies.get_max_hp enemy);
  Printf.printf "Damage: %d\n" (Enemies.get_atk enemy);
  Printf.printf "Block: %d\n" (Enemies.get_block enemy);
  Printf.printf "Intent: %s\n" (Enemies.intent_to_string enemy)

(** [print_enemy_defeated enemy] displays a message when the enemy is defeated.
*)
let print_enemy_defeated enemy =
  Printf.printf "\n%s has been defeated! (0 HP)\n" (Enemies.get_name enemy)

(** [string_of_keyword keyword] returns a readable name for a card keyword. *)
let string_of_keyword = function
  | Cards.Attack -> "Attack"
  | Cards.Defend -> "Defend"
  | Cards.Heal -> "Heal"
  | Cards.Draw -> "Draw"
  | Cards.Buff -> "Buff"

(** [print_card index card] displays a card's index, name, cost, and effect. *)
let print_card index card =
  (* temporary implementation that ignores all effects after the first one *)
  let effects = Cards.get_card_effect card in

  let keyword, amount =
    match effects with
    | [] -> failwith "Unimplemented multiple effects exception"
    | h :: t -> h
  in
  Printf.printf "%d. %s (Cost: %d) - %s %d\n" index (Cards.get_card_name card)
    (Cards.get_card_energy card)
    (string_of_keyword keyword)
    amount

(** [print_hand hand] displays the cards currently available to the player. *)
let print_hand hand =
  print_endline "\nYour current cards:";
  match hand with
  | [] -> print_endline "No cards in hand."
  | cards -> List.iteri (fun i card -> print_card (i + 1) card) cards

(** [print_combat_status player enemies hand goods_value cards_played
     max_cards_per_turn] displays the current combat information. *)
let print_combat_status player enemies hand goods_value cards_played
    max_cards_per_turn =
  print_section "COMBAT STATUS";
  print_player_stats player goods_value;
  List.iter print_enemy enemies;
  Printf.printf "\nCards played: %d/%d\n" cards_played max_cards_per_turn;
  print_hand hand

(** [print_reward amount] displays a gold reward. *)
let print_reward amount = Printf.printf "\nYou earned %d gold!\n" amount

(** [print_message message] displays a general message. *)
let print_message message = print_endline message

(** [print_selling_phase goods_value] displays the value of the goods held. *)
let print_selling_phase goods_value =
  print_section "FINAL SELLING PHASE";
  Printf.printf "Your goods are worth %d gold.\n" goods_value;
  print_endline "Goods have not been sold."

(** [print_final_report player score] displays the final report. *)
let print_final_report player score =
  print_section "FINAL REPORT";
  if Player.check_alive player then print_endline "The demo is complete!"
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
