open OUnit2
open SpiceLib

let make_rng () = Random.State.make [| 42 |]

let test_make_enemy _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  assert_equal "Goblin" (Enemies.get_name enemy);
  assert_equal 30 (Enemies.get_hp enemy);
  assert_equal 30 (Enemies.get_max_hp enemy);
  assert_equal 5 (Enemies.get_atk enemy);
  assert_equal 0 (Enemies.get_block enemy);
  assert_bool "Enemy should be alive" (Enemies.check_alive enemy)

let test_add_hp _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  assert_equal (Ok ()) (Enemies.add_hp (-10) enemy);
  assert_equal 20 (Enemies.get_hp enemy);
  assert_equal (Ok ()) (Enemies.add_hp 5 enemy);
  assert_equal 25 (Enemies.get_hp enemy)

let test_enemy_death _ =
  let enemy = Enemies.make_enemy "Goblin" 10 5 10 6 in
  assert_equal (Ok ()) (Enemies.add_hp (-10) enemy);
  assert_equal 0 (Enemies.get_hp enemy);
  assert_bool "Enemy should be dead" (not (Enemies.check_alive enemy));
  assert_bool "Dead enemy should reject HP changes"
    (match Enemies.add_hp 5 enemy with
    | Error _ -> true
    | Ok () -> false)

let test_add_atk _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  ignore (Enemies.add_atk 3 enemy);
  assert_equal 8 (Enemies.get_atk enemy);
  ignore (Enemies.add_atk (-2) enemy);
  assert_equal 6 (Enemies.get_atk enemy)

let test_set_block _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  Enemies.set_block 7 enemy;
  assert_equal 7 (Enemies.get_block enemy);
  Enemies.set_block 3 enemy;
  assert_equal 3 (Enemies.get_block enemy)

let test_intent _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  let intent = Enemies.choose_next_intent (make_rng ()) enemy in
  let current_intent = Enemies.get_intent enemy in
  assert_equal intent current_intent ~cmp:(fun a b ->
      match (a, b) with
      | Enemies.Attack x, Enemies.Attack y -> x = y
      | Enemies.Defend x, Enemies.Defend y -> x = y
      | Enemies.Pass, Enemies.Pass -> true
      | _ -> false)

let test_intent_to_string _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  assert_bool "Intent description should not be empty"
    (String.length (Enemies.intent_to_string enemy) > 0)

let test_init_enemy _ =
  let enemies = Enemies.init_enemies (make_rng ()) 1 in
  let enemy =
    match enemies with
    | [] -> assert_failure "No enemies initiated"
    | h :: t -> h
  in
  assert_bool "Generated enemy should have a name"
    (String.length (Enemies.get_name enemy) > 0);
  assert_bool "Generated enemy should have positive HP"
    (Enemies.get_hp enemy > 0)

let test_gold_drop _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  let gold = Enemies.get_gold_drop (make_rng ()) enemy in
  assert_bool "Gold drop should not be negative" (gold >= 0)

let test_scale_turn _ =
  let enemy = Enemies.make_enemy "Goblin" 30 5 10 6 in
  Enemies.scale_turn 1 enemy;
  assert_bool "Enemy attack should not be negative" (Enemies.get_atk enemy >= 0)

let suite =
  "enemies tests"
  >::: [
         "make enemy" >:: test_make_enemy;
         "add hp" >:: test_add_hp;
         "enemy death" >:: test_enemy_death;
         "add attack" >:: test_add_atk;
         "set block" >:: test_set_block;
         "intent" >:: test_intent;
         "intent to string" >:: test_intent_to_string;
         "initialize enemy" >:: test_init_enemy;
         "gold drop" >:: test_gold_drop;
         "scale turn" >:: test_scale_turn;
       ]

let () = run_test_tt_main suite
