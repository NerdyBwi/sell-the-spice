
type keyword =
| Attack
| Defend
| Heal
| Draw
| Buff
(** Keywords to determine effects of object*)

type rarity =
| Common
| Uncommon
| Rare
(** Type for different card pools *)

type t
(** Cards type, record of card name, card energy, and keywords+modifier 
((keyword * int) list. Paired int either represents a multiplier or the flat effects
depending on the keyword)*)


val generate_card : rarity -> Random.State.t -> t
(** [generate_card] takes in a card rarity (common, uncommon, rare) and rng seed and generates a
    corresponding card from their corresponding pools*)

val get_card_name : t -> string
(** [get_card_name] takes in the card type and returns its string name*)

val get_card_effect : t -> (keyword * int) list
(** [get_card_name] takes in the card type and returns a list of keyword and int tuples.*)

val get_card_energy : t -> int
(** [get_card_energy] takes in the card type and returns the energy cost.*)
