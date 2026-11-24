val print_banner : unit -> unit
(** [print_banner ()] displays the game's title and welcome message. *)

val print_section : string -> unit
(** [print_section title] displays a section heading. *)

val print_stage : int -> int -> unit
(** [print_stage stage total] displays the current stage. *)

val print_player_stats : Player.t -> int -> unit
(** [print_player_stats player goods_value] displays player statistics. *)

val print_enemy : Enemies.t -> unit
(** [print_enemy enemy] displays the enemy's current statistics and intent. *)

val print_enemy_defeated : Enemies.t -> unit
(** [print_enemy_defeated enemy] displays a message when the enemy is defeated.
*)

val print_hand : Cards.t list -> unit
(** [print_hand hand] displays the cards currently available to the player. *)

val print_card_details : Cards.t -> unit
(** [print_card_details card] displays the full details of a selected card. *)

val print_shop : Player.t -> (string * int * int) list -> unit
(** [print_shop player items] displays available shop items and their buying and
    selling prices. *)

val print_shop_inventory : Player.t -> unit
(** [print_shop_inventory player] displays the player's cards and goods. *)

val print_shop_menu : string -> int -> unit
(** [print_shop_menu mode item_count] displays the current shop mode and
    navigation options. *)

val print_buy_menu : (string * int) list -> unit
(** [print_buy_menu items] displays available items and their buying prices. *)

val print_sell_menu : (string * int) list -> unit
(** [print_sell_menu items] displays available goods and their selling prices.
*)

val print_card_purchase_options : unit -> unit
(** [print_card_purchase_options ()] displays the purchase and back options. *)

val print_shop_message : string -> unit
(** [print_shop_message message] displays a shop transaction message. *)

val print_combat_status :
  Player.t -> Enemies.t list -> Cards.t list -> int -> int -> int -> unit
(** [print_combat_status player enemies hand goods_value cards_played
     max_cards_per_turn] displays the current combat information. *)

val print_reward : int -> unit
(** [print_reward amount] displays a gold reward. *)

val print_message : string -> unit
(** [print_message message] displays a general message. *)

val print_selling_phase : int -> unit
(** [print_selling_phase goods_value] displays the value of held goods. *)

val print_final_report : Player.t -> int -> unit
(** [print_final_report player score] displays the final report. *)

val print_goodbye : unit -> unit
(** [print_goodbye ()] displays the closing message. *)
