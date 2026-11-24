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

(** [print_card_details card] displays the full details of a selected card. *)
let print_card_details card =
  print_section "CARD DETAILS";
  Printf.printf "Name: %s\n" (Cards.get_card_name card);
  Printf.printf "Energy cost: %d\n" (Cards.get_card_energy card);
  print_endline "Effects:";
  List.iter
    (fun (keyword, amount) ->
      Printf.printf "- %s %d\n" (string_of_keyword keyword) amount)
    (Cards.get_card_effect card)

(** [print_shop player items] displays the available shop items. Each item
    contains its name, buying price, and selling price. *)
let print_shop player items =
  print_section "SHOP";
  Printf.printf "Gold: %d\n" (Player.get_gold player);
  print_endline "\nAvailable items:";
  match items with
  | [] -> print_endline "No items available."
  | items ->
      List.iteri
        (fun i (name, buy_price, sell_price) ->
          Printf.printf "%d. %s | Buy: %d gold | Sell: %d gold\n" (i + 1) name
            buy_price sell_price)
        items

(** [print_shop_inventory player] displays the player's current cards and goods
    inventory. *)
let print_shop_inventory player =
  print_section "YOUR INVENTORY";
  Printf.printf "Gold: %d\n" (Player.get_gold player);

  print_endline "\nCards:";
  let deck = Player.get_deck player in
  if Array.length deck = 0 then print_endline "No cards."
  else
    Array.iteri
      (fun i card ->
        Printf.printf "%d. %s (Cost: %d)\n" (i + 1) (Cards.get_card_name card)
          (Cards.get_card_energy card))
      deck;

  print_endline "\nGoods:";
  let goods = Player.get_goods player in
  if Array.length goods = 0 then print_endline "No goods."
  else
    Array.iter
      (fun (good, count) ->
        Printf.printf "- %s x%d (Value: %d each)\n" (Goods.name good) count
          (Goods.value good))
      goods

(** [print_shop_menu mode item_count] displays the current shop mode and
    available choices. *)
let print_shop_menu mode item_count =
  print_endline ("\nCurrent mode: " ^ mode);
  Printf.printf "\n%d. Switch to %s\n" (item_count + 1)
    (if mode = "Buying" then "Selling" else "Buying");
  Printf.printf "%d. Leave shop\n" (item_count + 2);
  print_endline "\nEnter your choice:"

(** [print_buy_menu items] displays the available items and their prices. Each
    item is represented by its name and buying price. *)
let print_buy_menu items =
  print_section "BUY ITEMS";
  (match items with
  | [] -> print_endline "No items available."
  | items ->
      List.iteri
        (fun i (name, price) ->
          Printf.printf "%d. %s - %d gold\n" (i + 1) name price)
        items);
  print_endline "\n0. Back";
  print_endline "\nChoose an item to view its details:"

(** [print_sell_menu items] displays the goods available for selling. Each item
    is represented by its name and selling price. *)
let print_sell_menu items =
  print_section "SELL GOODS";
  (match items with
  | [] -> print_endline "You have no goods to sell."
  | items ->
      List.iteri
        (fun i (name, price) ->
          Printf.printf "%d. %s - %d gold\n" (i + 1) name price)
        items);
  print_endline "\n0. Back";
  print_endline "\nChoose a good to sell:"

(** [print_card_purchase_options ()] displays the purchase and back options. *)
let print_card_purchase_options () =
  print_endline "\n1. Purchase";
  print_endline "0. Back";
  print_endline "\nEnter your choice:"

(** [print_shop_message message] displays a shop transaction message. *)
let print_shop_message message = Printf.printf "\n%s\n" message

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
