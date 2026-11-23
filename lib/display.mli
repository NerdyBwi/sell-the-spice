val print_banner : unit -> unit
(** [print_banner ()] displays the game's title and welcome message. *)

val print_section : string -> unit
(** [print_section title] displays a section heading. *)

val print_stage : int -> int -> unit
(** [print_stage stage total] displays the current stage. *)

val print_player_stats : Player.t -> int -> unit
(** [print_player_stats player goods_value] displays the player's statistics. *)

val print_reward : int -> unit
(** [print_reward amount] displays a gold reward. *)

val print_message : string -> unit
(** [print_message message] displays a general message. *)

val print_selling_phase : int -> unit
(** [print_selling_phase goods_value] displays the selling summary. *)

val print_final_report : Player.t -> int -> unit
(** [print_final_report player score] displays the final report. *)

val print_goodbye : unit -> unit
(** [print_goodbye ()] displays the closing message. *)

val print_combat : Player.t -> Enemies.t list -> unit
(** [print_combat player enemies] displays the player's combat statistics and
    the first enemy in [enemies], or a message if no enemies remain. *)
