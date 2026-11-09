let debug = false (* manual debugging switch *)
let debug_point msg = if debug then () else print_endline ("Debugging: " ^ msg)

type t = {
  name : string;
  mutable hp : int;
  mutable hp_max : int;
  mutable atk : int;
  mutable gold : int;
  mutable deck : Cards.t option array;
  mutable goods : (Goods.t option * int) array;
}

(** [init_player name hp atk gold initial_deck_size initial_goods_size]
    generates a player with an initial state of the provided values. *)
let init_player name hp atk gold initial_deck_size initial_goods_size =
  {
    name;
    hp;
    hp_max = hp;
    atk;
    gold;
    deck = Array.init initial_deck_size (fun x -> None);
    goods = Array.init initial_goods_size (fun x -> (None, 0));
  }

(** Retrieves the name of the player. *)
let get_name player = player.name

(* ============================================================================
   Health functions
   ============================================================================ *)

(** Retrieves the HP of a player. *)
let get_hp player = player.hp

(** Retrieves the max HP of a player. *)
let get_max_hp player = player.hp_max

(** [check_alive player] checks if the player's HP is positive. Returns [true]
    if it is.*)
let check_alive player = player.hp > 0

(** [add_hp num player] adds that number of HP to the player's HP stat. Works
    with negative integers, and allows negative HP. Does not work on dead
    players. *)
let add_hp num player =
  if check_alive player then
    Ok (player.hp <- min (player.hp + num) player.hp_max)
  else
    Error
      (Printf.sprintf
         "Attempted to add [%d] to [HP: %d]; failed due to player not being \
          alive."
         num player.hp)

(** [add_max_hp num player] adds that number of HP to the player's max HP stat.
    Works with negative integers. Will lower the player's current hp, but will
    not lower it below 1. Will not increase player's current hp. Does not allow
    negative max HP. Does not work on dead players. *)
let add_max_hp num player =
  if check_alive player then
    let new_max = player.hp_max + num in
    if new_max > 0 then (
      player.hp_max <- new_max;
      if num < 0 then Ok (player.hp <- max 1 (player.hp + num)) else Ok ())
    else
      Error
        (Printf.sprintf
           "Attempted to add [%d] to [HP_max: %d]; failed due to result \
            causing player to have negative max HP."
           num player.hp)
  else
    Error
      (Printf.sprintf
         "Attempted to add [%d] to [HP_max: %d]; failed due to player not \
          being alive."
         num player.hp)

(* ============================================================================
   Gold functions
   ============================================================================ *)

(** Retrieves the number of gold the player has. *)
let get_gold player = player.gold

(** [add_gold num player] adds that number of gold to the player's gold stat.
    Works with negative integers. Does not allow a modification that would
    result in a negative gold balance. *)
let add_gold num player =
  let outcome = player.gold + num in
  if outcome > 0 then Ok (player.gold <- outcome)
  else
    Error
      (Printf.sprintf
         "Attempted to add [%d] to [Gold: %d]; failed due to negative gold \
          outcome."
         num player.gold)

(* ============================================================================
   Attack functions
   ============================================================================ *)

(** Retrieves the attack stat of a player. *)
let get_atk player = player.atk

(** [add_atk num player] adds that number of atk to the player's atk stat. Works
    with negative integers. Does not allow a modification that would result in a
    negative atk balance. *)
let add_atk num player =
  let outcome = player.atk + num in
  if outcome > 0 then Ok (player.atk <- outcome)
  else
    Error
      (Printf.sprintf
         "Attempted to add [%d] to [Atk: %d]; failed due to negative atk \
          outcome."
         num player.atk)

(* ============================================================================
   Deck functions
   ============================================================================ *)

(** Retrieves the deck of cards in a player's inventory. Does not contain empty
    deck slots. Does not give cards in any particular order. *)
let get_deck player =
  player.deck |> Array.to_list
  |> List.fold_left
       (fun acc card ->
         match card with
         | Some thing -> thing :: acc
         | None -> acc)
       []
  |> Array.of_list

(** Retrieves the max size of the deck of cards in the player's inventory. *)
let get_deck_size player = Array.length player.deck

let deck_modifier_helper card (modify_value : Cards.t option) player e_msg =
  let deck = player.deck in
  deck
  |> Array.find_index (fun x ->
      match x with
      | Some thing when thing = card -> true
      | _ -> false)
  |> function
  | None -> Error e_msg
  | Some i -> Ok (deck.(i) <- modify_value)

(** Error string given when a good cannot be found in the inventory*)
let error_str_unfound_card_remove =
  "Attempted to remove a card from the deck; failed due to card not found."

(** Error string given when there are no empty deck slots for adding a card.*)
let error_str_no_card_slots =
  "Attempted to add to the deck; failed due to no empty deck slots."

(** Error string given when a good cannot be found in the inventory*)
let error_str_excess_deck_size_remove =
  "Attempted to remove deck size; failed due to too few resultant slots."

(** [add_card card count player] adds that number of cards to a player's deck.
    Returns an Error if the player has no more deck slots. *)
let add_card card player =
  deck_modifier_helper card (Some card) player error_str_no_card_slots

(** [remove_card card player] removes that card from the player's deck. Returns
    an Error if the deck does not contain that card. *)
let remove_card card player =
  deck_modifier_helper card None player error_str_no_card_slots

(**[shuffle_deck rand_state player] takes a random state and shuffles the
   player's deck of cards. *)
let shuffle_deck rand_state player =
  Ok (Array.shuffle ~rand:(Random.State.int rand_state) player.deck)

(** [add_deck_size num player] adds [num] deck slots to the player's deck. Works
    with negative integers. Does not allow for a modification that would result
    in less slots than currently held cards. Does not allow for a modification
    that would result in a negative number of deck slots. *)
let add_deck_size n player =
  let current_size = get_deck_size player in
  let current_deck = get_deck player in
  let occupied_length = Array.length current_deck in
  if occupied_length > current_size - n then
    Error error_str_excess_deck_size_remove
  else
    let new_deck =
      Array.init (current_size + n) (fun i ->
          if i < occupied_length then
            let card = current_deck.(i) in
            Some card
          else None)
    in
    Ok (player.deck <- new_deck)

(* ============================================================================
   Goods inventory functions
   ============================================================================ *)

(** Retrieves the player's goods inventory. Each entry contains the good and the
    count of the good. Does not contain empty inventory slots. *)
let get_goods player =
  player.goods |> Array.to_list
  |> List.fold_left
       (fun acc (opt, count) ->
         match opt with
         | Some good -> (good, count) :: acc
         | None -> acc)
       []
  |> Array.of_list

(** Retrieves the max size of the player's goods inventory. *)
let get_goods_size player = Array.length player.goods

(** Error string given when a good cannot be found in the inventory*)
let error_str_unfound_good_remove =
  "Attempted to remove a good from the inventory; failed due to good not being \
   found."

(** Error string given when removing this amount of good results in negative
    count in the inventory*)
let error_str_excess_good_remove =
  "Attempted to remove a good from the inventory; failed due to outcome count \
   being negative."

(** Error string given when there are no empty inventory slots for adding a
    good.*)
let error_str_no_good_slots =
  "Attempted to add a good to the inventory; failed due to no available \
   inventory slot."

(** Error string given when attempting to add a negative number of goods.*)
let error_str_negative_good_add_count =
  "Attempted to add a good to the inventory; failed due to adding negative \
   count."

(** Error string given when attempting to add a negative number of goods.*)
let error_str_negative_good_remove_count =
  "Attempted to remove a good from the inventory; failed due to removing \
   negative count."

(** Error string given when removing this number of inventory slots results too
    few slots.*)
let error_str_excess_good_size_remove =
  "Attempted to remove inventory slots; failed due to resultant size being too \
   small."

(** [add_good good count player] adds that number of goods to a player's
    inventory. Returns an Error if the count is negative, or if the player has
    no more inventory slots. *)
let add_good good count player =
  if count < 0 then Error error_str_negative_good_add_count
  else
    let inventory = player.goods in
    inventory
    |> Array.find_index (fun x ->
        match x with
        | Some thing, held when thing = good -> true
        | _ -> false)
    |> function
    | Some i -> Ok (inventory.(i) <- (Some good, snd inventory.(i) + count))
    | None -> (
        let i =
          Array.find_index
            (fun x ->
              match x with
              | None, _ -> true
              | _ -> false)
            inventory
        in
        match i with
        | Some i_none -> Ok (inventory.(i_none) <- (Some good, count))
        | None -> Error error_str_no_good_slots)

(** [remove_good_amount good count player] removes a number of goods from a
    player's inventory. Does not modify the player's stats. Returns an Error if
    the count is negative, or if the good cannot be found. *)
let remove_good_amount good count player =
  if count < 0 then Error error_str_negative_good_remove_count
  else
    let inventory = player.goods in
    inventory
    |> Array.find_index (fun x ->
        match x with
        | Some thing, held when thing = good -> true
        | _ -> false)
    |> function
    | Some i ->
        let _, current_count = inventory.(i) in
        if count > current_count then Error error_str_excess_good_remove
        else (
          inventory.(i) <- (Some good, snd inventory.(i) - count);
          let _, new_count = inventory.(i) in
          if new_count = 0 then Ok (inventory.(i) <- (None, 0)) else Ok ())
    | None -> Error error_str_unfound_good_remove

(** [remove_good good player] removes all of the goods from the player's
    inventory with that associated name. Returns the number of goods removed
    from the player if successful. Returns an error if the good cannot be found.
*)
let remove_good good player =
  let inventory = player.goods in
  inventory
  |> Array.find_index (fun x ->
      match x with
      | Some thing, held when thing = good -> true
      | _ -> false)
  |> function
  | Some i ->
      inventory.(i) <- (None, 0);
      Ok (snd inventory.(i))
  | None -> Error error_str_unfound_good_remove

(** [add_good_size num player] adds [num] inventory slots to the player's goods
    inventory. Works with negative integers. Does not allow for a modification
    that would result in less slots than currently held items. Does not allow
    for a modification that would result in a negative number of inventory
    slots. *)
let add_good_size n player =
  let current_size = get_goods_size player in
  let current_inventory = get_goods player in
  let occupied_length = Array.length current_inventory in
  if occupied_length > current_size - n then
    Error error_str_excess_good_size_remove
  else
    let new_bag =
      Array.init (current_size + n) (fun i ->
          if i < occupied_length then
            let thing, amount = current_inventory.(i) in
            (Some thing, amount)
          else (None, 0))
    in
    Ok (player.goods <- new_bag)
