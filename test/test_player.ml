(* Specification tests for Player. Deck tests only cover sizes for now: Cards is
   still a stub that fails when the module loads, so no Cards.t value can be
   created yet. *)

open OUnit2
open SpiceLib

(* ---------- Helpers ---------- *)

let pint = string_of_int

let pres = function
  | Ok () -> "Ok ()"
  | Error e -> "Error " ^ e

let pres_int = function
  | Ok n -> "Ok " ^ string_of_int n
  | Error e -> "Error " ^ e

let good name =
  match Goods.of_name name with
  | Some g -> g
  | None -> failwith ("test setup: no good named " ^ name)

let saffron = good "Saffron" (* price 30, value 42 *)
let salt = good "Salt" (* price 2, value 3 *)
let pepper = good "Black Pepper" (* price 5, value 6 *)
let clove = good "Clove" (* price 10, value 13 *)
let vanilla = good "Vanilla" (* price 22, value 30 *)

(* A fresh player: 100 hp, 10 atk, 50 gold, 5 deck slots, 3 goods slots. *)
let fresh () = Player.init_player "Tester" 100 10 50 5 3

(* [count p g] is how many [g] the player holds (0 if none). *)
let count p g =
  Player.get_goods p |> Array.to_list
  |> List.find_opt (fun (g', _) -> g' = g)
  |> Option.fold ~none:0 ~some:snd

let ok r = assert_equal ~printer:pres (Ok ()) r
let err e r = assert_equal ~printer:pres (Error e) r

let is_error r =
  assert_bool ("expected Error, got " ^ pres r) (Result.is_error r)

let add p g n = ok (Player.add_good g n p)

(* ---------- Init and getters ---------- *)

let init_tests =
  [
    ( "init sets every field" >:: fun _ ->
      let p = fresh () in
      assert_equal ~printer:Fun.id "Tester" (Player.get_name p);
      assert_equal ~printer:pint 100 (Player.get_hp p);
      assert_equal ~printer:pint 100 (Player.get_max_hp p);
      assert_equal ~printer:pint 10 (Player.get_atk p);
      assert_equal ~printer:pint 50 (Player.get_gold p);
      assert_equal ~printer:pint 5 (Player.get_deck_size p);
      assert_equal ~printer:pint 3 (Player.get_goods_size p);
      assert_equal ~printer:pint 0 (Array.length (Player.get_deck p));
      assert_equal ~printer:pint 0 (Array.length (Player.get_goods p)) );
    ( "new player is alive" >:: fun _ ->
      assert_bool "alive" (Player.check_alive (fresh ())) );
  ]

(* ---------- Gold ---------- *)

let gold_tests =
  [
    ( "add_gold adds" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_gold 10 p);
      assert_equal ~printer:pint 60 (Player.get_gold p) );
    ( "add_gold subtracts" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_gold (-20) p);
      assert_equal ~printer:pint 30 (Player.get_gold p) );
    ( "add_gold can spend down to exactly 0" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_gold (-50) p);
      assert_equal ~printer:pint 0 (Player.get_gold p) );
    ( "add_gold below 0 is Error and leaves gold unchanged" >:: fun _ ->
      let p = fresh () in
      is_error (Player.add_gold (-51) p);
      assert_equal ~printer:pint 50 (Player.get_gold p) );
  ]

(* ---------- Atk ---------- *)

let atk_tests =
  [
    ( "add_atk adds" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_atk 5 p);
      assert_equal ~printer:pint 15 (Player.get_atk p) );
    ( "add_atk subtracts" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_atk (-4) p);
      assert_equal ~printer:pint 6 (Player.get_atk p) );
    (* Spec only forbids a negative atk; ask Owen whether 0 is meant to be
       OK. *)
    ( "add_atk down to exactly 0 (spec: only negative forbidden)" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_atk (-10) p);
      assert_equal ~printer:pint 0 (Player.get_atk p) );
    ( "add_atk below 0 is Error and leaves atk unchanged" >:: fun _ ->
      let p = fresh () in
      is_error (Player.add_atk (-11) p);
      assert_equal ~printer:pint 10 (Player.get_atk p) );
  ]

(* ---------- HP (beyond test_player_functions.ml) ---------- *)

let hp_tests =
  [
    ( "healing past max is capped at max" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_hp (-30) p);
      ok (Player.add_hp 1000 p);
      assert_equal ~printer:pint 100 (Player.get_hp p) );
    ( "add_max_hp to 0 is Error and changes nothing" >:: fun _ ->
      let p = fresh () in
      is_error (Player.add_max_hp (-100) p);
      assert_equal ~printer:pint 100 (Player.get_max_hp p);
      assert_equal ~printer:pint 100 (Player.get_hp p) );
    ( "add_max_hp never lowers hp below 1" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_hp (-70) p);
      (* hp 30 *)
      ok (Player.add_max_hp (-50) p);
      assert_equal ~printer:pint 50 (Player.get_max_hp p);
      assert_equal ~printer:pint 1 (Player.get_hp p);
      assert_bool "alive" (Player.check_alive p) );
    ( "hp of exactly 0 is dead" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_hp (-100) p);
      assert_bool "dead" (not (Player.check_alive p)) );
  ]

(* ---------- Goods inventory ---------- *)

let add_good_tests =
  [
    ( "add_good puts a new good in a slot" >:: fun _ ->
      let p = fresh () in
      add p saffron 2;
      assert_equal ~printer:pint 2 (count p saffron);
      assert_equal ~printer:pint 1 (Array.length (Player.get_goods p)) );
    ( "adding the same good stacks instead of using a new slot" >:: fun _ ->
      let p = fresh () in
      add p saffron 2;
      add p saffron 3;
      assert_equal ~printer:pint 5 (count p saffron);
      assert_equal ~printer:pint 1 (Array.length (Player.get_goods p)) );
    ( "negative add count is Error" >:: fun _ ->
      let p = fresh () in
      err Player.error_str_negative_good_add_count
        (Player.add_good saffron (-1) p);
      assert_equal ~printer:pint 0 (Array.length (Player.get_goods p)) );
    ( "full inventory rejects a new kind of good" >:: fun _ ->
      let p = fresh () in
      add p salt 1;
      add p pepper 1;
      add p clove 1;
      err Player.error_str_no_good_slots (Player.add_good saffron 1 p);
      assert_equal ~printer:pint 0 (count p saffron) );
    ( "full inventory still stacks a good already held" >:: fun _ ->
      let p = fresh () in
      add p salt 1;
      add p pepper 1;
      add p clove 1;
      add p salt 4;
      assert_equal ~printer:pint 5 (count p salt) );
  ]

let remove_good_tests =
  [
    ( "remove_good_amount removes part of a stack" >:: fun _ ->
      let p = fresh () in
      add p saffron 5;
      ok (Player.remove_good_amount saffron 2 p);
      assert_equal ~printer:pint 3 (count p saffron) );
    ( "removing a whole stack frees its slot" >:: fun _ ->
      let p = fresh () in
      add p salt 1;
      add p pepper 1;
      add p clove 2;
      ok (Player.remove_good_amount clove 2 p);
      assert_equal ~printer:pint 2 (Array.length (Player.get_goods p));
      add p saffron 1;
      assert_equal ~printer:pint 1 (count p saffron) );
    ( "removing more than held is Error and changes nothing" >:: fun _ ->
      let p = fresh () in
      add p saffron 3;
      err Player.error_str_excess_good_remove
        (Player.remove_good_amount saffron 4 p);
      assert_equal ~printer:pint 3 (count p saffron) );
    ( "negative remove count is Error" >:: fun _ ->
      let p = fresh () in
      add p saffron 3;
      err Player.error_str_negative_good_remove_count
        (Player.remove_good_amount saffron (-1) p);
      assert_equal ~printer:pint 3 (count p saffron) );
    ( "removing a good not held is Error" >:: fun _ ->
      let p = fresh () in
      err Player.error_str_unfound_good_remove
        (Player.remove_good_amount saffron 1 p) );
    ( "remove_good returns how many were removed" >:: fun _ ->
      let p = fresh () in
      add p saffron 5;
      assert_equal ~printer:pres_int (Ok 5) (Player.remove_good saffron p);
      assert_equal ~printer:pint 0 (count p saffron);
      assert_equal ~printer:pint 0 (Array.length (Player.get_goods p)) );
    ( "remove_good on a good not held is Error" >:: fun _ ->
      let p = fresh () in
      assert_equal ~printer:pres_int
        (Error Player.error_str_unfound_good_remove)
        (Player.remove_good saffron p) );
  ]

(* ---------- Selling ---------- *)

let sell_tests =
  [
    ( "sell_good_amount at 1.0 pays price * count" >:: fun _ ->
      let p = fresh () in
      add p saffron 3;
      ok (Player.sell_good_amount saffron 1.0 2 p);
      assert_equal ~printer:pint (50 + (2 * 30)) (Player.get_gold p);
      assert_equal ~printer:pint 1 (count p saffron) );
    ( "sell_good_amount at 0.5 rounds down" >:: fun _ ->
      let p = fresh () in
      add p pepper 3;
      (* 3 * 5 * 0.5 = 7.5 -> 7 *)
      ok (Player.sell_good_amount pepper 0.5 3 p);
      assert_equal ~printer:pint 57 (Player.get_gold p);
      assert_equal ~printer:pint 0 (count p pepper) );
    ( "sell_good sells the whole stack for gold" >:: fun _ ->
      let p = fresh () in
      add p saffron 3;
      ok (Player.sell_good saffron 1.0 p);
      assert_equal ~printer:pint (50 + (3 * 30)) (Player.get_gold p);
      assert_equal ~printer:pint 0 (count p saffron) );
    ( "selling a good not held changes nothing" >:: fun _ ->
      let p = fresh () in
      err Player.error_str_unfound_good_remove
        (Player.sell_good_amount saffron 1.0 1 p);
      err Player.error_str_unfound_good_remove (Player.sell_good saffron 1.0 p);
      assert_equal ~printer:pint 50 (Player.get_gold p) );
    ( "selling more than held changes nothing" >:: fun _ ->
      let p = fresh () in
      add p saffron 2;
      err Player.error_str_excess_good_remove
        (Player.sell_good_amount saffron 1.0 3 p);
      assert_equal ~printer:pint 50 (Player.get_gold p);
      assert_equal ~printer:pint 2 (count p saffron) );
  ]

(* ---------- Inventory and deck sizes ---------- *)

let size_tests =
  [
    ( "add_good_size grows an empty inventory" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_good_size 2 p);
      assert_equal ~printer:pint 5 (Player.get_goods_size p) );
    ( "add_good_size grows a full inventory and keeps its goods" >:: fun _ ->
      let p = fresh () in
      add p salt 1;
      add p pepper 2;
      add p clove 3;
      ok (Player.add_good_size 2 p);
      assert_equal ~printer:pint 5 (Player.get_goods_size p);
      assert_equal ~printer:pint 3 (count p clove);
      add p saffron 1;
      assert_equal ~printer:pint 1 (count p saffron) );
    ( "add_good_size shrinking below held goods is Error, no goods lost"
    >:: fun _ ->
      let p = fresh () in
      add p salt 1;
      add p pepper 2;
      is_error (Player.add_good_size (-2) p);
      assert_equal ~printer:pint 3 (Player.get_goods_size p);
      assert_equal ~printer:pint 2 (Array.length (Player.get_goods p)) );
    ( "add_good_size can shrink empty slots" >:: fun _ ->
      let p = fresh () in
      add p salt 1;
      ok (Player.add_good_size (-2) p);
      assert_equal ~printer:pint 1 (Player.get_goods_size p);
      assert_equal ~printer:pint 1 (count p salt) );
    ( "add_good_size to a negative size is Error" >:: fun _ ->
      let p = fresh () in
      is_error (Player.add_good_size (-5) p);
      assert_equal ~printer:pint 3 (Player.get_goods_size p) );
    ( "add_deck_size grows and shrinks an empty deck" >:: fun _ ->
      let p = fresh () in
      ok (Player.add_deck_size 3 p);
      assert_equal ~printer:pint 8 (Player.get_deck_size p);
      ok (Player.add_deck_size (-6) p);
      assert_equal ~printer:pint 2 (Player.get_deck_size p) );
    ( "add_deck_size to a negative size is Error" >:: fun _ ->
      let p = fresh () in
      is_error (Player.add_deck_size (-6) p);
      assert_equal ~printer:pint 5 (Player.get_deck_size p) );
    ( "shuffling an empty deck is Ok" >:: fun _ ->
      let p = fresh () in
      ok (Player.shuffle_deck (Random.State.make [| 1 |]) (Player.get_deck p))
    );
  ]

(* ---------- Link to Goods scoring ---------- *)

let score_tests =
  [
    ( "inventory_value of get_goods matches hand total" >:: fun _ ->
      let p = fresh () in
      add p salt 5;
      add p vanilla 2;
      (* 5 * 3 + 2 * 30 = 75 *)
      assert_equal ~printer:pint 75 (Goods.inventory_value (Player.get_goods p))
    );
  ]

let () =
  run_test_tt_main
    ("Player (spec)"
    >::: init_tests @ gold_tests @ atk_tests @ hp_tests @ add_good_tests
         @ remove_good_tests @ sell_tests @ size_tests @ score_tests)
