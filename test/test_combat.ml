open OUnit2
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
   Testing Helper Functions
   =========================================================================== *)

(**[assert_equal_int expected actual] *)
let assert_equal_int x y = assert_equal ~printer:(fun i -> string_of_int i) x y

let is_ok v =
  match v with
  | Ok _ -> ()
  | Error e -> assert_failure e

let not_is_ok v =
  match v with
  | Ok _ -> assert_failure "expected error"
  | Error e -> ()

let demo_card = Cards.generate_card "common"

let build_jim () =
  let jim = P.init_player "jim" 100 50 25 15 5 in
  is_ok (P.add_card demo_card jim);
  is_ok (P.add_card demo_card jim);
  is_ok (P.add_card demo_card jim);
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
   Tests
   =========================================================================== *)

let init_combat_demo () =
  let player = build_jim () in
  let enemies = [ build_tom () ] in
  let combat_state = C.init_combat rng player enemies in
  while not (C.is_over combat_state) do
    print_endline "waiting on an input: ";
    let input = read_line () |> int_of_string_opt in
    C.run_combat rng combat_state input;
    combat_print_demo combat_state
  done;
  print_endline "Combat Over"

(* ===========================================================================
   Running Tests
   =========================================================================== *)
let tests =
  "Test suite for combat module tests"
  >::: [ ("Test 1" >:: fun _ -> ()); ("Test 2" >:: fun _ -> ()) ]
;;

if d then print_endline "Running test_player_functions";;

let () = init_combat_demo ()
(* let _ = run_test_tt_main tests *)
