open OUnit2
open SpiceLib
open SpiceLib.Player

let d = false
(* debug switch*)

(** debug point *)
let dbp s = if d then print_endline (Printf.sprintf "Debugging: %s" s)

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

let player_init_test () =
  let name = "jim" in
  let initial_hp = 67 in
  let initial_atk = 23 in
  let initial_gold = 1042 in
  let initial_deck_size = 5 in
  let initial_goods_size = 10 in
  let p =
    init_player name initial_hp initial_atk initial_gold initial_deck_size
      initial_goods_size
  in
  assert_equal name (get_name p);
  assert_equal_int initial_hp (get_hp p);
  assert_equal_int initial_hp (get_max_hp p);
  assert_equal_int initial_atk (get_atk p);
  assert_equal_int initial_deck_size (get_deck_size p);
  assert_equal_int 0 (Array.length (get_deck p));
  assert_equal_int initial_goods_size (get_goods_size p);
  assert_equal_int 0 (Array.length (get_goods p))

let player_hp_test () =
  let name = "jim" in
  let initial_hp = 67100 in
  let initial_atk = 23 in
  let initial_gold = 1042 in
  let initial_deck_size = 5 in
  let initial_goods_size = 10 in
  let p =
    init_player name initial_hp initial_atk initial_gold initial_deck_size
      initial_goods_size
  in
  let died_too_early_str p =
    Printf.sprintf "player died too early: hp of %d" (get_hp p)
  in
  let died_too_late_str p =
    Printf.sprintf
      "Expected dead player when checking a player with negative HP: %d"
      (get_hp p)
  in
  let tdbp i = dbp ("Point " ^ string_of_int i ^ " passed") in
  (* adding hp while at full hp has no effect *)
  add_hp 50 p |> is_ok;
  assert_equal_int initial_hp (get_hp p);
  assert_equal_int initial_hp (get_max_hp p);
  assert_bool (died_too_early_str p) (check_alive p);
  tdbp 1;

  (* adding negative hp removes hp but does not change max hp *)
  add_hp (-50) p |> is_ok;
  assert_equal_int (initial_hp - 50) (get_hp p);
  assert_equal_int initial_hp (get_max_hp p);
  assert_bool (died_too_early_str p) (check_alive p);
  tdbp 2;

  (* adding max hp does not change hp but does increase max hp *)
  add_max_hp 50 p |> is_ok;
  assert_equal_int (initial_hp - 50) (get_hp p);
  assert_equal_int (initial_hp + 50) (get_max_hp p);
  assert_bool (died_too_early_str p) (check_alive p);
  tdbp 3;

  (* adding negative max hp does not change hp if it does not reach hp but does
     decrease max hp *)
  add_max_hp (-100) p |> is_ok;
  assert_equal_int (initial_hp - 150) (get_hp p);
  assert_equal_int (initial_hp - 50) (get_max_hp p);
  assert_bool (died_too_early_str p) (check_alive p);
  tdbp 4;

  (* reducing hp to 1*)
  add_max_hp ((-1 * (initial_hp - 50)) + 1) p |> is_ok;
  assert_equal_int 1 (get_max_hp p);
  assert_equal_int 1 (get_hp p);
  assert_bool (died_too_early_str p) (check_alive p);
  tdbp 5;

  (* adding negative hp below current hp causes player to die *)
  add_hp (-2) p |> is_ok;
  assert_equal_int (-1) (get_hp p);
  assert_equal_int 1 (get_max_hp p);
  assert_bool (died_too_late_str p) (not (check_alive p));
  tdbp 6;

  (* attempting to add hp to a dead player does nothing.*)
  add_hp 42 p |> not_is_ok;
  assert_equal_int (-1) (get_hp p);
  assert_equal_int 1 (get_max_hp p);
  assert_bool (died_too_late_str p) (not (check_alive p));
  tdbp 7;

  (* attempting to add max hp to a dead player does nothing.*)
  add_max_hp 67 p |> not_is_ok;
  assert_equal_int (-1) (get_hp p);
  assert_equal_int 1 (get_max_hp p);
  assert_bool (died_too_late_str p) (not (check_alive p));
  tdbp 8

let tests =
  "Test suite for player module tests"
  >::: [
         ("Player initiation test" >:: fun _ -> player_init_test ());
         ("Player HP modification test" >:: fun _ -> player_hp_test ());
       ]
;;

if d then print_endline "Running test_player_functions";;

let _ = run_test_tt_main tests
