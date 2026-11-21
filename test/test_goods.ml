open OUnit2
open SpiceLib

let pint = string_of_int
let names goods = List.map Goods.name goods

let find name =
  match Goods.of_name name with
  | Some g -> g
  | None -> failwith ("test setup: no good named " ^ name)

(* ---------- Catalog (checks the representation invariant) ---------- *)

let catalog_tests =
  [
    ( "catalog has 10 goods" >:: fun _ ->
      assert_equal ~printer:pint 10 (List.length Goods.all) );
    ( "names are unique" >:: fun _ ->
      let ns = names Goods.all in
      assert_equal ~printer:pint (List.length ns)
        (List.length (List.sort_uniq compare ns)) );
    ( "names are non-empty" >:: fun _ ->
      List.iter (fun g -> assert_bool "empty name" (Goods.name g <> "")) Goods.all
    );
    ( "prices positive, values non-negative" >:: fun _ ->
      List.iter
        (fun g ->
          assert_bool (Goods.name g ^ " price") (Goods.price g > 0);
          assert_bool (Goods.name g ^ " value") (Goods.value g >= 0))
        Goods.all );
  ]

(* ---------- of_name ---------- *)

let of_name_tests =
  [
    ( "finds every good by its own name" >:: fun _ ->
      List.iter
        (fun g -> assert_equal (Some g) (Goods.of_name (Goods.name g)))
        Goods.all );
    ( "unknown name is None" >:: fun _ ->
      assert_equal None (Goods.of_name "Unobtainium") );
    ("empty name is None" >:: fun _ -> assert_equal None (Goods.of_name ""));
    ( "match is case-sensitive" >:: fun _ ->
      assert_equal None (Goods.of_name "saffron") );
  ]

(* ---------- random_selection ---------- *)

let rng seed = Random.State.make [| seed |]

let random_selection_tests =
  [
    ( "same seed gives same selection" >:: fun _ ->
      assert_equal
        ~printer:(String.concat ", ")
        (names (Goods.random_selection (rng 42) 4))
        (names (Goods.random_selection (rng 42) 4)) );
    ( "returns n goods" >:: fun _ ->
      assert_equal ~printer:pint 3
        (List.length (Goods.random_selection (rng 1) 3)) );
    ( "n = 0 gives empty list" >:: fun _ ->
      assert_equal [] (Goods.random_selection (rng 1) 0) );
    ( "n larger than catalog gives every good" >:: fun _ ->
      let sel = Goods.random_selection (rng 1) 100 in
      assert_equal ~printer:pint (List.length Goods.all) (List.length sel);
      List.iter (fun g -> assert_bool "missing good" (List.mem g sel)) Goods.all
    );
    ( "no duplicates, all from catalog" >:: fun _ ->
      let sel = Goods.random_selection (rng 7) 6 in
      assert_equal ~printer:pint 6 (List.length (List.sort_uniq compare sel));
      List.iter (fun g -> assert_bool "not in all" (List.mem g Goods.all)) sel
    );
    ( "negative n raises Invalid_argument" >:: fun _ ->
      assert_raises (Invalid_argument "Goods.random_selection: negative count")
        (fun () -> Goods.random_selection (rng 1) (-1)) );
  ]

(* ---------- inventory_value ---------- *)

let inventory_value_tests =
  [
    ( "empty inventory is worth 0" >:: fun _ ->
      assert_equal ~printer:pint 0 (Goods.inventory_value [||]) );
    ( "single entry is value * count" >:: fun _ ->
      let saffron = find "Saffron" in
      assert_equal ~printer:pint
        (3 * Goods.value saffron)
        (Goods.inventory_value [| (saffron, 3) |]) );
    ( "sums several entries" >:: fun _ ->
      (* Salt is worth 3, Vanilla 30: 5*3 + 2*30 = 75 *)
      assert_equal ~printer:pint 75
        (Goods.inventory_value [| (find "Salt", 5); (find "Vanilla", 2) |]) );
    ( "zero count adds nothing" >:: fun _ ->
      assert_equal ~printer:pint 0
        (Goods.inventory_value [| (find "Clove", 0) |]) );
  ]

(* ---------- to_string ---------- *)

let contains s sub =
  let n = String.length sub in
  let rec go i =
    i + n <= String.length s && (String.sub s i n = sub || go (i + 1))
  in
  go 0

let to_string_tests =
  [
    ( "mentions name, price and description" >:: fun _ ->
      let g = find "Cardamom" in
      let s = Goods.to_string g in
      assert_bool "name" (contains s (Goods.name g));
      assert_bool "price" (contains s (string_of_int (Goods.price g)));
      assert_bool "description" (contains s (Goods.description g)) );
  ]

let () =
  run_test_tt_main
    ("Goods"
    >::: catalog_tests @ of_name_tests @ random_selection_tests
         @ inventory_value_tests @ to_string_tests)
