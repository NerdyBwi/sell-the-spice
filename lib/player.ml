let debug = false (* manual debugging switch *)
let debug_point msg = if debug then () else print_endline ("Debugging: " ^ msg)

type t = {
  name : string;
  mutable hp : int;
  mutable atk : int;
  mutable gold : int;
  deck : Cards.t option array;
  goods : (Goods.t option * int) array;
}

(** [init_player name hp atk gold initial_deck_size initial_goods_size]
    generates a player with an initial state of the provided values. *)
let init_player name hp atk gold initial_deck_size initial_goods_size =
  {
    name;
    hp;
    atk;
    gold;
    deck = Array.init initial_deck_size (fun x -> None);
    goods = Array.init initial_goods_size (fun x -> (None, 0));
  }

(** Retrieves the name of the player. *)
let get_name player = player.name

(** Retrieves the attack stat of a player. *)
let get_atk player = player.atk

(* 
 ===================================
  Health functions 
 =================================== 
*)

(** Retrieves the HP of a player. *)
let get_hp player = player.hp

(** [check_alive player] checks if the player's HP is positive. Returns [true]
    if it is.*)
let check_alive player = player.hp > 0

(** [add_hp num player] adds that number of HP to the player's HP stat. Works
    with negative integers, and allows negative HP. *)
let add_hp num player =
  if check_alive player then Ok (player.hp <- num)
  else
    Error
      (Printf.sprintf
         "Attempted to add [%d] to [HP: %d]; failed due to player not being \
          alive."
         num player.hp)

(* 
 ===================================
  Gold functions 
 =================================== 
*)

(** Retrieves the number of gold the player has. *)
let get_gold player = player.gold

(** [add_gold num player] adds that number of gold to the player's gold stat.
    Works with negative integers. Returns an Error if such modification would
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

(*
 ===================================
  Deck functions 
 =================================== 
*)

(** Retrieves the deck of cards in a player's inventory. Does not contain empty
    deck slots. Does not give cards in any particular order. *)
let get_deck player =
  player.deck |> Array.to_list
  |> List.fold_left
       (fun acc card ->
         match card with Some thing -> thing :: acc | None -> acc)
       []
  |> Array.of_list

(** Retrieves the max size of the deck of cards in the player's inventory. *)
let get_deck_size player = Array.length player.deck

let deck_modifier_helper card (modify_value : Cards.t option) player e_msg =
  let deck = player.deck in
  deck
  |> Array.find_index (fun x ->
      match x with Some thing when thing = card -> true | _ -> false)
  |> function
  | None -> Error e_msg
  | Some i -> Ok (deck.(i) <- modify_value)

(** [add_card card count player] adds that number of cards to a player's deck.
    Returns an Error if the player has no more deck slots. *)
let add_card card player =
  let e_msg =
    "Attempted to add to the deck; failed due to no empty deck slots."
  in
  deck_modifier_helper card (Some card) player e_msg

(** [remove_card card player] removes that card from the player's deck. Returns
    an Error if the deck does not contain that card. *)
let remove_card card player =
  let e_msg =
    "Attempted to remove a card from the deck; failed due to card not found."
  in
  deck_modifier_helper card None player e_msg

(**[shuffle_deck rand_state player] takes a random state and shuffles the
   player's deck of cards. *)
let shuffle_deck rand_state player =
  Array.shuffle ~rand:(Random.State.int rand_state) player.deck

(*
 ===================================
  Goods functions 
 =================================== 
*)

(** Retrieves the player's goods inventory. Each entry contains the good and the
    count of the good. Does not contain empty inventory slots. *)
let get_goods player =
  player.goods |> Array.to_list
  |> List.fold_left
       (fun acc (opt, count) ->
         match opt with Some good -> (good, count) :: acc | None -> acc)
       []
  |> Array.of_list

(** Retrieves the max size of the player's goods inventory. *)
let get_goods_size player = Array.length player.goods

(** [add_good good count player] adds that number of goods to a player's
    inventory and returns a new player when done. Returns an Error if the count
    is negative, or if the player has no more inventory slots. *)
let add_good good count player =
  if count < 0 then
    Error
      "Attempted to add a good to the inventory; failed due to adding negative \
       count."
  else
    let inventory = player.goods in
    inventory
    |> Array.find_index (fun x ->
        match x with Some thing, held when thing = good -> true | _ -> false)
    |> function
    | Some i -> Ok (inventory.(i) <- (Some good, snd inventory.(i) + count))
    | None -> (
        let i =
          Array.find_index
            (fun x -> match x with None, _ -> true | _ -> false)
            inventory
        in
        match i with
        | Some i_none -> Ok (inventory.(i_none) <- (Some good, count))
        | None ->
            Error
              "Attempted to add a good to the inventory; failed due to no \
               available inventory slot.")

(** [remove_good_amount good count player] removes a number of goods from a
    player's inventory. *)
let remove_good_amount good count player =
  let inventory = player.goods in
  inventory
  |> Array.find_index (fun x ->
      match x with Some thing, held when thing = good -> true | _ -> false)
  |> function
  | Some i -> Ok (inventory.(i) <- (Some good, snd inventory.(i) - count))
  | None ->
      Error
        "Attempted to remove a good from the inventory; failed due to good not \
         being found."

(** [remove_good good player] removes all of the goods from the player's
    inventory with that associated name. Returns the number of goods removed
    from the player if successful. *)
let remove_good good player =
  let inventory = player.goods in
  inventory
  |> Array.find_index (fun x ->
      match x with Some thing, held when thing = good -> true | _ -> false)
  |> function
  | Some i ->
      inventory.(i) <- (None, 0);
      Ok (snd inventory.(i))
  | None ->
      Error
        "Attempted to remove a good from the inventory; failed due to good not \
         being found."
