type t
(** Cards type, record of keywords+modifier ((string * int) list)*)

val generate_card : string -> t
(** takes in a card rarity (common, uncommon, rare) and generates a
    corresponding card*)
