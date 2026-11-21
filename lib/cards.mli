type keyword =
  | Attack
  | Defend
  | Heal
  | Draw
  | Buff

type t
(** Cards type, record of card name, card cost, and keywords+modifier ((keyword
    * int) list)*)

val generate_card : string -> t
(** takes in a card rarity (common, uncommon, rare) and generates a
    corresponding card*)

val get_card_name : t -> string
val get_card_effect : t -> keyword * int
val get_card_cost : t -> int
