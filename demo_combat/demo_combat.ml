open SpiceLib
module C = Combat
module E = Enemies
module P = Player
module G = Goods

let d = false
(* debug switch*)

(** debug point *)
let dbp s = if d then print_endline (Printf.sprintf "Debugging: %s" s)

let seed = 1
let rng = Random.State.make [| seed |]
(* ===========================================================================
   demo helper functions
   =========================================================================== *)

let print_error = function
  | Ok () -> ()
  | Error e -> print_endline e

let demo_card = Cards.generate_card "common"

let build_jim () =
  let jim = P.init_player "jim" 100 2 25 15 5 in
  print_error (P.add_card demo_card jim);
  print_error (P.add_card demo_card jim);
  jim

let build_fat_jim () =
  let jim = P.init_player "jim" 100 2 25 15 5 in
  for i = 0 to 14 do
    print_error (P.add_card demo_card jim)
  done;
  jim

let build_tom () = E.make_enemy "tom" 10 9 8 7

let combat_print_demo c =
  let p = C.get_player c in
  let p_name, p_atk, p_hp, p_mhp, p_gd, p_b =
    P.(get_name p, get_atk p, get_hp p, get_max_hp p, get_gold p, C.get_block c)
  in
  let es = C.get_enemies c in
  let e =
    match es with
    | [] -> failwith "how are there no enemies in here bruh"
    | h :: t -> h
  in
  let e_name, e_atk, e_hp, e_mhp, e_gd, e_b =
    E.
      ( get_name e,
        get_atk e,
        get_hp e,
        get_max_hp e,
        get_gold_drop rng e,
        get_block e )
  in
  let h, i_played, turn = (C.get_hand c, C.get_cards_played c, C.get_turn c) in
  let lester =
    Printf.sprintf
      "Player: %s\n\
      \ ATK: %d | HP: %d/%d | BLOCK: %d | GLD: %d\n\n\
       Enemy: %s\n\
       ATK:%d | HP: %d/%d | BLOCK: %d | GLD: %d\n\
       Intent: %s\n\n\
       Turn:%d | Cards Played: %d\n\n\
      \ Your current cards:\n\
       %s"
      p_name p_atk p_hp p_mhp p_b p_gd e_name e_atk e_hp e_mhp e_b e_gd
      (E.intent_to_string e) turn i_played
      (List.fold_right (fun c acc -> Cards.get_card_name c ^ "\n" ^ acc) h "")
  in
  print_endline lester

(* ===========================================================================
   demo function
   =========================================================================== *)

let init_combat_demo player_builder enemy_builder =
  let player = player_builder () in
  let tom = enemy_builder () in
  let enemies = [ tom ] in
  let combat_state = C.init_combat rng player enemies in
  combat_print_demo combat_state;
  while not (C.is_over combat_state) do
    print_endline "waiting on an input: ";
    let input = read_line () |> int_of_string_opt in
    C.run_combat rng combat_state input;

    print_endline "\n \n \n \n ";
    print_endline "\027[2J\027[H";
    flush stdout;
    combat_print_demo combat_state;

    print_endline
      ("debugging: determined tom = alive is "
      ^ string_of_bool (E.check_alive tom));

    print_endline
      ("debugging: status of combat = is_over is "
      ^ string_of_bool (C.is_over combat_state))
  done;
  print_endline "Combat Over"

(* ===========================================================================
   running the thing
   =========================================================================== *)

(* let () = init_combat_demo build_jim build_tom *)
let () = init_combat_demo build_fat_jim build_tom
