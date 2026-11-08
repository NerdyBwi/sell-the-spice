(* Use a command-line seed when provided; otherwise generate one. *)
let get_seed () =
  match Array.length Sys.argv with
  | 1 ->
      Random.self_init ();
      Random.bits ()
  | 2 ->
      (try
         int_of_string Sys.argv.(1)
       with Failure _ ->
         prerr_endline "Error: seed must be an integer.";
         exit 1)
  | _ ->
      prerr_endline "Usage: main.exe [seed]";
      exit 1

(* Start the game and handle input or runtime errors. *)
let () =
  try
    let seed = get_seed () in
    Printf.printf "Using random seed: %d\n" seed;
    Sell_the_spice.Game.start_game seed
  with
  | End_of_file ->
      print_endline "\nInput ended. Exiting game."
  | error ->
      prerr_endline
        ("An unexpected error occurred: "
         ^ Printexc.to_string error);
      exit 1
