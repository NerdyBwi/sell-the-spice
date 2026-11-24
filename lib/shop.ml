type item =
  | Cards of Cards.t
  | Goods of Goods.t  (** Variant of cards/goods/anything else in shop*)

type slot = {
  item : item;
  buy_price : int;
  sell_price : int;
}

type transaction_result =
  | Complete
  | Empty_slot
  | Not_enough_gold
  | Not_enough_good
  | Not_sellable
  | Invalid_action

type t = slot option array
(** Shop type, contains an array of item/price tuple*)

type shop_state =
  | Buying
  | Selling
  | Leaving

type state = {
  shop : t;
  player : Player.t;
  status : shop_state;
}

let create_slot slot_item buy sell =
  Some { item = slot_item; buy_price = buy; sell_price = sell }

(** Takes in rng seed to generate shop *)
let init_shop seed player_data =
  let card1 = create_slot (Cards Cards.(generate_card Common seed)) 10 0 in
  let card2 = create_slot (Cards Cards.(generate_card Uncommon seed)) 20 0 in
  let card3 = create_slot (Cards Cards.(generate_card Rare seed)) 30 0 in
  let goods_list = Goods.random_selection seed 3 in

  let convert_goods =
    List.map
      (fun good ->
        create_slot (Goods good) (Goods.price good) (Goods.value good))
      goods_list
  in

  let shop_list = [ card1; card2; card3 ] @ convert_goods in

  let shop_array = Array.of_list shop_list in
  { shop = shop_array; player = player_data; status = Buying }

let get_buy_price shop index =
  if index < 0 || index >= Array.length shop then
    invalid_arg "Index is out of bounds"
  else
    match shop.(index) with
    | Some slot -> Some slot.buy_price
    | None -> None

let get_sell_price shop index =
  if index < 0 || index >= Array.length shop then
    invalid_arg "Index is out of bounds"
  else
    match shop.(index) with
    | Some slot -> Some slot.sell_price
    | None -> None

let get_item_name =
  if index < 0 || index >= Array.length shop then
    invalid_arg "Index is out of bounds"
  else
    match shop.(index) with
    | Some slot -> (
        match slot.item with
        | Cards card -> Cards.get_card_name card
        | Goods good -> Goods.name good)
    | None -> "EMPTY"

let get_all_data shop =
  let shop_list = Array.to_list shop in
  List.filter_map
    (fun slot ->
      match slot with
      | None -> None
      | Some slot -> Some (slot.item, slot.buy_price, slot.sell_price))
    shop_list

let remove_item shop index =
  if index < 0 || index >= Array.length shop then
    invalid_arg "Index is out of bounds"
  else shop.(index) <- None

(** Takes in index of item and shop and returns *)
let purchase_item shop index player =
  if index < 0 || index >= Array.length shop then
    invalid_arg "Index is out of bounds"
  else
    let item = shop.(index) in
    match item with
    | None -> Empty_slot
    | Some slot -> (
        let item_type = slot.item in
        let cost = slot.buy_price in
        let funds = Player.get_gold player in
        if cost > funds then Not_enough_gold
        else
          match item_type with
          | Cards card -> (
              match Player.add_card card player with
              | Error e -> Invalid_action
              | Ok () ->
                  ignore (Player.add_gold (-cost) player);
                  remove_item shop index;
                  Complete)
          | Goods good -> (
              match Player.add_good good 1 player with
              | Error e -> Invalid_action
              | Ok () ->
                  ignore (Player.add_gold (-cost) player);
                  Complete))

let sell_goods shop index player =
  if index < 0 || index >= Array.length shop then
    invalid_arg "Index is out of bounds"
  else
    let item = shop.(index) in
    match item with
    | None -> Empty_slot
    | Some slot -> (
        let item_type = slot.item in
        match item_type with
        | Cards _ -> Not_sellable
        | Goods good -> (
            match Player.remove_good_amount good 1 player with
            | Error _ -> Not_enough_good
            | Ok () -> (
                match Player.add_gold slot.sell_price player with
                | Error e ->
                    failwith ("shop sell error: " ^ e)
                    (* this error is fatal because it should never happen and
                       right now we're still in development trying to iron out
                       bugs. *)
                | Ok () -> Complete)))

let check_shop_status state = state.status

let run_shop state input_option =
  match input_option with
  | None -> (state, Invalid_action)
  | Some input ->
      if input >= 0 && input < Array.length state.shop then
        match state.status with
        | Buying ->
            let result = purchase_item state.shop input state.player in
            (state, result)
        | Selling ->
            let result = sell_goods state.shop input state.player in
            (state, result)
        | Leaving -> ({ state with status = Leaving }, Invalid_action)
      else if input = Array.length state.shop then
        let status = state.status in
        match status with
        | Buying -> ({ state with status = Selling }, Complete)
        | Selling -> ({ state with status = Buying }, Complete)
        | Leaving -> ({ state with status = Leaving }, Invalid_action)
      else if input = Array.length state.shop + 1 then
        ({ state with status = Leaving }, Complete)
      else (state, Invalid_action)
