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

type t
(** Cards type, record of card name, card energy, and keywords+modifier 
((keyword * int) list)*)


val generate_card : rarity -> Random.State.t -> t
(** takes in a card rarity (common, uncommon, rare) and rng seed and generates a
    corresponding card*)

val get_card_name : t -> string

val get_card_effect : t -> (keyword * int)

val get_card_energy : t -> int

