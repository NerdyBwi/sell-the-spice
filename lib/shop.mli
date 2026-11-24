type t
(** Shop type, contains an array of items*)

type item
(** Variant of cards/goods/anything else in shop*)

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

(** Variant for outcome of a transaction request*)

type shop_state =
  | Buying
  | Selling
  | Leaving
(** Variant for determining the available actions at the shop*)

type state = {
  shop : t;
  player : Player.t;
  status : shop_state;
}
(** a preliminary state holding the 
information about the current shop, player state, and status of the current shop*)

val init_shop : Random.State.t -> Player.t -> state
(** Takes in rng seed to generate shop *)

val get_buy_price : t -> int -> int option
(** Takes in shop and index of item and returns buy price*)

val get_sell_price : t -> int -> int option
(** Takes in shop and index of item and returns sell price*)

val get_item_name : t -> int -> string
(** Takes in shop and index of item and returns the name of the item *)

val get_all_data : t -> (string*int*int)
(** Takes in a shop object and return a list of tuples containing 
the names and buy/sell information of everything in the shop*)

val purchase_item : t -> int -> Player.t -> transaction_result
(** Takes in index of item and shop and returns the result of the attempted
    purchase of the item*)

val sell_goods : t -> int -> Player.t -> transaction_result
(** Takes in index of item and shop and returns Not_sellable if its a card and
    the result of the sale if its a good*)

val check_shop_status : state -> shop_state
(** Returns the state of the shop instance entered*)

val run_shop : state -> int option -> state * transaction_result
(** Takes in a state and input to perform a transaction 
based on the state's status and input, and returns the new state and result of that
transaction*)
