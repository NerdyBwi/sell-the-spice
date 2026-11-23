type item = 
| Cards of Cards.t
| Goods of Goods.t
(** Variant of cards/goods/anything else in shop*)

type purchase_result =
| Purchased
| Empty_slot
| Not_enough_gold

type t = (item*int) option array
(** Shop type, contains an array of item/price tuple*)




(** Takes in rng seed to generate shop *)
let init_shop seed = 
let card1 = Cards.generate_card Card.Common seed in
let card2 = Cards.generate_card Card.Uncommon seed in
let card3 = Cards.generate_card Card.Rare seed in
let goods_list = Goods.random_selection seed 1 in
let good1 = List.hd goods_list in


[| Some (Cards card1,10); Some (Cards card2,20); Some (Cards card3,30);
 Some (Goods good1,Goods.price good1); None|];


let get_price shop index = 
if index < 0 || index >= Array.length shop then 
invalid_arg "Index is out of bounds"
else 
match shop.(index) with
| Some (_, price) -> Some price
| None -> None

let remove_item shop index=
if index < 0 ||index >= Array.length shop then 
invalid_arg "Index is out of bounds"
else 
shop.(index) <- None


(** Takes in index of item and shop and returns *)
let purchase_item shop index player = 
if index < 0 ||index >= Array.length shop then
invalid_arg "Index is out of bounds"
else 
let cost = get_price shop index in
match cost with 
| None -> Empty_slot
| Some price -> 
let funds = Player.get_gold player in
if price <= funds then 
Player.add_gold (-price);
remove_item shop index;
Purchased
else 
Not_enough_gold



