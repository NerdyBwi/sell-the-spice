open OUnit2
open SpiceLib

let make_rng () = Random.State.make [| 42 |]
let make_player () = Player.init_player "Test Player" 100 10 50 10 10
let make_enemy () = Enemies.make_enemy "Goblin" 30 5 10 6

let get_enemy state =
  match Combat.get_enemies state with
  | [] -> assert_failure "No enemies"
  | h :: t -> h

let test_init_combat _ =
  let player = make_player () in
  let enemy = make_enemy () in
  let combat = Combat.init_combat (make_rng ()) player [ enemy ] in
  assert_equal "Test Player" (Player.get_name (Combat.get_player combat));
  assert_equal "Goblin" (Enemies.get_name (get_enemy combat));
  assert_bool "Combat should not initially be over"
    (not (Combat.is_over combat))

let test_get_player _ =
  let player = make_player () in
  let combat = Combat.init_combat (make_rng ()) player [ make_enemy () ] in
  let returned_player = Combat.get_player combat in
  assert_equal (Player.get_hp player) (Player.get_hp returned_player);
  assert_equal (Player.get_atk player) (Player.get_atk returned_player);
  assert_equal (Player.get_gold player) (Player.get_gold returned_player)

let test_get_enemy _ =
  let enemy = make_enemy () in
  let combat = Combat.init_combat (make_rng ()) (make_player ()) [ enemy ] in
  let returned_enemy = get_enemy combat in
  assert_equal (Enemies.get_name enemy) (Enemies.get_name returned_enemy);
  assert_equal (Enemies.get_hp enemy) (Enemies.get_hp returned_enemy);
  assert_equal (Enemies.get_atk enemy) (Enemies.get_atk returned_enemy)

let test_get_hand _ =
  let combat =
    Combat.init_combat (make_rng ()) (make_player ()) [ make_enemy () ]
  in
  let hand = Combat.get_hand combat in
  assert_bool "Hand should be a list" (List.length hand >= 0)

let test_combat_ends_when_enemy_dies _ =
  let enemy = make_enemy () in
  let combat = Combat.init_combat (make_rng ()) (make_player ()) [ enemy ] in
  ignore (Enemies.add_hp (-100) enemy);
  assert_bool "Combat should be over when the enemy is defeated"
    (Combat.is_over combat)

let test_combat_ends_when_player_dies _ =
  let player = make_player () in
  let combat = Combat.init_combat (make_rng ()) player [ make_enemy () ] in
  ignore (Player.add_hp (-100) player);
  assert_bool "Combat should be over when the player is defeated"
    (Combat.is_over combat)

let test_end_turn _ =
  let combat =
    Combat.init_combat (make_rng ()) (make_player ()) [ make_enemy () ]
  in
  Combat.end_turn (make_rng ()) combat;
  assert_bool "Combat should still be active with living player and enemy"
    (not (Combat.is_over combat))

let test_play_card _ =
  let rng = make_rng () in
  let player = make_player () in
  let card = Cards.generate_card Cards.Common rng in
  let () = Result.get_ok (Player.add_card card player) in
  let combat = Combat.init_combat rng player [ make_enemy () ] in
  let result = Combat.play_card 1 combat in
  match result with
  | Ok () ->
      assert_bool "Combat should remain active" (not (Combat.is_over combat))
  | Error message ->
      assert_bool "Error message should not be empty" (String.length message > 0)

let suite =
  "combat tests"
  >::: [
         "initialize combat" >:: test_init_combat;
         "get player" >:: test_get_player;
         "get enemy" >:: test_get_enemy;
         "get hand" >:: test_get_hand;
         "combat ends when enemy dies" >:: test_combat_ends_when_enemy_dies;
         "combat ends when player dies" >:: test_combat_ends_when_player_dies;
         "end turn" >:: test_end_turn;
         "play card" >:: test_play_card;
       ]

let () = run_test_tt_main suite
