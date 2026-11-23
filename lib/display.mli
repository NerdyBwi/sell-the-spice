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
