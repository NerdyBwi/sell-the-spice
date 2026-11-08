(* [{ name; description; price; value }] is the kind of good called [name],
   costing [price] gold to buy and adding [value] to the final score.
  [name] is non-empty, [price > 0], [value >= 0]. *)
type t = { name : string; description : string; price : int; value : int }

let name g = g.name
let description g = g.description
let price g = g.price
let value g = g.value

(* still need to create list of spices *)
let all : t list = []
let of_name _ = failwith "TODO: Goods.of_name"
let random_selection _ _ = failwith "TODO: Goods.random_selection"
let inventory_value _ = failwith "TODO: Goods.inventory_value"
let to_string _ = failwith "TODO: Goods.to_string"
