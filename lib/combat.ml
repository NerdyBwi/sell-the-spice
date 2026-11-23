(** Handles turn-based interactions between the player, enemies, and cards *)

type status =
  | Ongoing
  | Finished

type t = {
  player : Player.t;
  mutable block : int;
  mutable enemies : Enemies.t list;
  mutable status : status;
  mutable turn : int;
  mutable cards_played : int;
  (* contains a counter for where the draw should start from *)
  mutable draw_pile : Cards.t array * int;
  mutable hand : Cards.t list;
}

(**Variable that can be changed internally to change the number of cards that
   can be played per turn. *)
let max_cards_per_turn = 3

(**Variable that can be changed internally to change the number of cards drawn
   per turn. *)
let max_cards_drawn_per_turn = 5

(** float * int operator *)
let ( *.* ) f i = f *. float_of_int i

(** int * float operator *)
let ( **. ) i f = float_of_int i *. f

(* ============================================================================
   State functions
   ============================================================================ *)

(** Retrieves the player in the combat encounter. *)
let get_player s = s.player

(** Retrieves the enemies in the combat encounter. *)
let get_enemies s = s.enemies

(** [get_block state] retrieves the player's current temporary block. *)
let get_block s = s.block

(** [get_turn state] retrieves the current turn number. *)
let get_turn s = s.turn

(** Retrieves the cards currently in the player's hand. *)
let get_hand s = s.hand

(** [get_cards_played state] retrieves how many cards have been played on the
    current turn. *)
let get_cards_played s = s.cards_played

(** [is_over state] checks if the combat encounter has ended. *)
let is_over s =
  match s.status with
  | Ongoing -> false
  | Finished -> true

(* ============================================================================
   Turn functions
   ============================================================================ *)

(** error string for if shuffling somehow fails, (which it should never do, of
    course). *)
let shuffle_error e =
  Printf.sprintf
    "Unexpected error: [%s] from attempting to shuffle the deck of cards while \
     in combat!"
    e

(**[draw_hand state] takes a combat state and draws [max_cards_per_turn] cards
   from the draw_pile.*)
let draw_hand rng state =
  let draw_deck, start_i = state.draw_pile in
  let size = Array.length draw_deck in
  let rec construct_hand acc loc counter =
    (* Recursive helper method for drawing cards. [acc] is the accumulator list,
       [loc] is the current position in the array, [counter] is current the
       number of cards drawn *)
    if counter >= max_cards_drawn_per_turn || loc >= size then (acc, loc)
    else
      let acc' = draw_deck.(loc) :: acc in
      construct_hand acc' (loc + 1) (counter + 1)
  in
  let new_hand, end_i = construct_hand [] start_i 0 in
  if end_i < size then (
    (* not overdrawn case *)
    state.draw_pile <- (draw_deck, end_i);
    state.hand <- new_hand)
  else
    (* overdrawn case *)
    match Player.shuffle_deck rng draw_deck with
    | Error e -> failwith (shuffle_error e)
    | Ok _ ->
        state.draw_pile <- (draw_deck, 0);
        state.hand <- new_hand

(** [init_combat rng player enemies] initializes a combat encounter (state)
    between [player] and [enemies]. *)
let init_combat rng (player : Player.t) (enemies : Enemies.t list) =
  let draw_pile = Player.get_deck player in
  match Player.shuffle_deck rng draw_pile with
  | Error e ->
      (* an error result here is completely unexpected *)
      failwith (shuffle_error e)
  | Ok _ ->
      let state =
        {
          player;
          block = 0;
          enemies;
          status = Ongoing;
          turn = 1;
          cards_played = 0;
          draw_pile = (draw_pile, 0);
          hand = [];
        }
      in
      draw_hand rng state;
      state

(** Helper function [find_enemy enemies] finds the first enemy in a list of
    enemies that is not dead and returns it as an option.*)
let find_enemy lst =
  List.fold_left
    (fun acc e -> if Enemies.check_alive e then Some e else acc)
    None lst

(** [deal_damage_to_enemy damage target] applies [damage] to [target], absorbing
    damage with [target]'s block before reducing HP. *)
let deal_damage_to_enemy damage target =
  let damage = max 0 damage in
  let block = Enemies.get_block target in
  let absorbed = min block damage in
  Enemies.set_block (block - absorbed) target;
  let remaining = damage - absorbed in
  if remaining > 0 then Enemies.add_hp (-remaining) target else Ok ()

(** [deal_damage_to_player damage state] applies [damage] to the player in
    [state], absorbing damage with [state.block] before reducing HP. *)
let deal_damage_to_player damage state =
  let damage = max 0 damage in
  let absorbed = min state.block damage in
  state.block <- state.block - absorbed;
  let remaining = damage - absorbed in
  if remaining > 0 && Player.check_alive state.player then
    ignore (Player.add_hp (-remaining) state.player)

(** [execute_enemy_turn enemy state] resolves [enemy]'s planned action. *)
let execute_enemy_turn enemy state =
  if Enemies.check_alive enemy then begin
    Enemies.set_block 0 enemy;
    match Enemies.get_intent enemy with
    | Enemies.Attack damage -> deal_damage_to_player damage state
    | Enemies.Defend amount -> Enemies.set_block amount enemy
    | Enemies.Pass -> ()
  end

(** [use_card card state] performs the effect of the [card] during the player's
    turn. Returns an Error if the card cannot be played. *)
let use_card (c : Cards.t) (s : t) =
  let open Cards in
  let keyword, value = get_card_effect c in
  match keyword with
  | Attack -> (
      match find_enemy s.enemies with
      | None -> Error "No enemies available that can be targetted!"
      | Some target ->
          let damage = Player.get_atk (get_player s) * value in
          Enemies.add_hp (-1 * damage) target)
  | Defend -> Ok (s.block <- s.block + value)
  | Heal -> Player.add_hp value (get_player s)
  | Draw -> Error "Unimplemented card type: Draw"
  | Buff -> Error "Unimplmented card type: Buff"

(** [play_card input state] plays the card associated with [input] from the
    player's hand. Returns an Error if the card cannot be played / the input is
    invalid. *)
let play_card (i : int) (s : t) =
  if i < 0 then Error "Invalid input, cannot select a negative hand index."
  else
    let hand = get_hand s in
    let size = List.length hand in
    if i > size then Error "Invalid input"
    else
      let helper_choose_card acc card =
        (* takes a card, checks if the input matches the current index, then
           choose to keep the new card or to add it to the new hand and
           increments the index. *)
        let held, temp_hand, loc = acc in
        if i = loc then (* is the target card *)
          (Some card, temp_hand, loc + 1)
        else (* not the target card *)
          (held, card :: temp_hand, loc + 1)
      in

      let selected_card_opt, new_hand, _ =
        List.fold_left helper_choose_card (None, [], 0) hand
      in
      match selected_card_opt with
      | None ->
          (* this branch should never occur in theory *)
          Error "Could not find card in hand"
      | Some selected_card -> (
          match use_card selected_card s with
          | Error e ->
              (* card was not consumed, so we don't remove it *) Error e
          | Ok () ->
              (* card was consumed, so we do remove it *)
              Ok (s.hand <- new_hand))

(** [end_turn rng state] ends the player's turn and executes the enemies' turn.
*)
let end_turn (rng : Random.State.t) (state : t) =
  (* draws a new hand at the end of the player's turn *)
  if (not (Player.check_alive state.player)) || find_enemy state.enemies = None
  then state.status <- Finished
  else begin
    draw_hand rng state;
    List.iter (fun enemy -> execute_enemy_turn enemy state) state.enemies;
    state.block <- 0;
    state.cards_played <- 0;
    state.turn <- state.turn + 1;
    List.iter
      (fun enemy ->
        if Enemies.check_alive enemy then begin
          Enemies.scale_turn state.turn enemy;
          ignore (Enemies.choose_next_intent rng enemy)
        end)
      state.enemies
  end

(**Helper function that checks if any end turn conditions have been met.
   Specifically checks if a hand has no cards left, if there any valid enemies
   remaining, or if the game is over.

   Does not check if the number of cards played has reached the maximum. *)
let end_turn_condition state =
  List.length (get_hand state) <= 0
  || find_enemy (get_enemies state) = None
  || is_over state (* this condition is probably never met... *)

(** [run_combat rng state input] advances the combat phase by modifying [state]
    when given an [input] action. [None] inputs are needed to initiate enemy
    turns or something. *)
let run_combat (rng : Random.State.t) (state : t) (input_opt : int option) =
  if get_cards_played state >= max_cards_per_turn || end_turn_condition state
  then
    (* an end turn condition has been met *)
    end_turn rng state
  else (* it is the player's turn. *)
    match input_opt with
    | None ->
        (*probably an invalid input, we'll just ignore it and do nothing*)
        ()
    | Some input -> (
        (*note: we do input - 1 because humans start counting at 1, not 0*)
        match play_card (input - 1) state with
        | Error _ -> () (* does nothing *)
        | Ok () ->
            state.cards_played <- state.cards_played + 1;
            if end_turn_condition state then (* recheck end cond. *)
              end_turn rng state)
