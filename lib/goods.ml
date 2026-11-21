(* AF: [{ name; description; price; value }] is the kind of good called [name],
   costing [price] gold to buy and adding [value] to the final score.
   RI: [name] is non-empty, [price > 0], [value >= 0]. No two goods in [all]
   share a [name]. *)
type t = {
  name : string;
  description : string;
  price : int;
  value : int;
}

let name g = g.name
let description g = g.description
let price g = g.price
let value g = g.value

(* ---------- Catalog, cheapest first ---------- *)

let salt =
  {
    name = "Salt";
    description = "Cheap and everywhere, but it adds up.";
    price = 2;
    value = 3;
  }

let pepper =
  {
    name = "Black Pepper";
    description = "A sailor's staple. Sells steadily.";
    price = 5;
    value = 6;
  }

let turmeric =
  {
    name = "Turmeric";
    description = "Golden powder that stains everything.";
    price = 6;
    value = 8;
  }

let cinnamon =
  {
    name = "Cinnamon";
    description = "Curled bark with a sweet, warm smell.";
    price = 8;
    value = 10;
  }

let clove =
  {
    name = "Clove";
    description = "Tiny dried buds with a sharp bite.";
    price = 10;
    value = 13;
  }

let nutmeg =
  {
    name = "Nutmeg";
    description = "Once worth more than its weight in gold.";
    price = 12;
    value = 15;
  }

let cardamom =
  {
    name = "Cardamom";
    description = "Green pods prized by every merchant.";
    price = 15;
    value = 20;
  }

let star_anise =
  {
    name = "Star Anise";
    description = "Pretty to look at. Buyers are fickle.";
    price = 18;
    value = 22;
  }

let vanilla =
  {
    name = "Vanilla";
    description = "Slow to grow and hard to come by.";
    price = 22;
    value = 30;
  }

let saffron =
  {
    name = "Saffron";
    description = "Red threads picked by hand. Worth a fortune.";
    price = 30;
    value = 42;
  }

let all =
  [
    salt;
    pepper;
    turmeric;
    cinnamon;
    clove;
    nutmeg;
    cardamom;
    star_anise;
    vanilla;
    saffron;
  ]

(* ---------- Operations ---------- *)

let of_name s = List.find_opt (fun g -> g.name = s) all

let random_selection rng n =
  if n < 0 then invalid_arg "Goods.random_selection: negative count"
  else
    let goods = Array.of_list all in
    Array.shuffle ~rand:(Random.State.int rng) goods;
    let count = min n (Array.length goods) in
    Array.to_list (Array.sub goods 0 count)

let inventory_value inv =
  Array.fold_left (fun total (g, count) -> total + (g.value * count)) 0 inv

let to_string g = Printf.sprintf "%s (%d gold): %s" g.name g.price g.description
