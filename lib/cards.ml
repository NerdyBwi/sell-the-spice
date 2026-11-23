type keyword =
  | Attack
  | Defend
  | Heal
  | Draw
  | Buff

type t = {
  name : string;
  ef : keyword * int;
  cost : int;
}

(** this is a temporary implementation and does not reflect the final build in
    any meaningful way. *)
let generate_card s = { name = "test123"; ef = (Attack, 1); cost = 1 }

let get_card_name c = c.name
let get_card_effect c = c.ef
let get_card_cost c = c.cost
