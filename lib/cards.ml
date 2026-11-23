type keyword =
  | Attack
  | Defend
  | Heal
  | Draw
  | Buff

type rarity =
  | Common
  | Uncommon
  | Rare

type t = {
  name : string;
  energy : int;
  effects : (keyword * int) list;
}

let common1 = { name = "Common1"; energy = 0; effects = [ (Attack, 3) ] }
let common2 = { name = "Common2"; energy = 0; effects = [ (Attack, 4) ] }

let uncommon1 =
  { name = "Uncommon1"; energy = 0; effects = [ (Attack, 2); (Defend, 5) ] }

let uncommon2 =
  { name = "Uncommon2"; energy = 0; effects = [ (Attack, 5); (Defend, 2) ] }

let rare1 = { name = "Rare1"; energy = 0; effects = [ (Attack, 10) ] }

let rare2 =
  { name = "Rare2"; energy = 0; effects = [ (Defend, 4); (Heal, 10) ] }

let common_pool = [| common1; common2 |]
let uncommon_pool = [| uncommon1; uncommon2 |]
let rare_pool = [| rare1; rare2 |]

let generate_from_pool seed pool =
  let index = Random.State.int seed (Array.length pool) in
  pool.(index)

(** takes in a card rarity (common, uncommon, rare) and generates a
    corresponding card*)
let generate_card rarity seed =
  match rarity with
  | Common -> generate_from_pool seed common_pool
  | Uncommon -> generate_from_pool seed uncommon_pool
  | Rare -> generate_from_pool seed rare_pool

let get_card_name card = card.name
let get_card_effect card = card.effects
let get_card_energy card = card.energy
