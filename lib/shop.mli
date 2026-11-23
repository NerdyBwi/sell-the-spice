type t
(** Shop type, contains an array of items*)

type item
(** Variant of cards/goods/anything else in shop*)

type slot =
{
    object : item;
    buy_price : int;
    sell_price : int;
}

type transaction_result =
| Complete
| Empty_slot
| Not_enough_gold
| Not_enough_good
| Not_sellable

(** Variant for outcome of a transaction request*)

type t = slot option array
(** Shop type, contains an array of item/price tuple*)

val init_shop : Random.State.t -> t
(** Takes in rng seed to generate shop *)

val get_buy_price : t -> int -> int option
(** Takes in shop and index of item and returns buy price*)

val get_sell_price : t -> int -> int option
(** Takes in shop and index of item and returns sell price*)

val purchase_item : t -> int -> Player.t -> transaction_result
(** Takes in index of item and shop and returns 
the result of the attempted purchase of the item*)

val sell_goods : t -> int -> Player.t -> transaction_result
(** Takes in index of item and shop and returns Not_sellable if its a card and 
the result of the sale if its a good*)
