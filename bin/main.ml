open SpiceLib

(* Name used when the player doesn't enter one. *)
let default_name = "Merchant"

(* [parse_seed s] is [Some n] if [s], trimmed, is an integer [n]. *)
let parse_seed s = int_of_string_opt (String.trim s)

(* [clean_name s] is [s] trimmed, or [default_name] if that is empty. *)
let clean_name s =
  match String.trim s with
  | "" -> default_name
  | name -> name

(* Print [prompt] and read one line of input. *)
let ask prompt =
  print_string prompt;
  flush stdout;
  read_line ()

(* Generate a fresh seed from the system's randomness. *)
let random_seed () =
  Random.self_init ();
  Random.bits ()

(* Ask for a seed until the input is blank (random seed) or an integer. *)
let rec ask_seed () =
  match ask "Enter a seed (leave blank for random): " with
  | s when String.trim s = "" -> random_seed ()
  | s -> (
      match parse_seed s with
      | Some seed -> seed
      | None ->
          print_endline "Seeds must be whole numbers. Try again.";
          ask_seed ())

(* Use a command-line seed when provided; otherwise ask for one. *)
let get_seed () =
  match Array.length Sys.argv with
  | 1 -> ask_seed ()
  | 2 -> (
      match parse_seed Sys.argv.(1) with
      | Some seed -> seed
      | None ->
          prerr_endline "Error: seed must be an integer.";
          exit 1)
  | _ ->
      prerr_endline "Usage: SellTheSpice [seed]";
      exit 1

(* Ask for the player's name, falling back to a default when blank. *)
let get_name () = clean_name (ask "What's your merchant's name? ")

(* Run the intro, start the game, and handle input or runtime errors. *)
let () =
  try
    let seed = get_seed () in
    let name = get_name () in
    Printf.printf "Welcome, %s! Using random seed: %d\n" name seed;
    (* TODO: pass [name] once Game.start_game accepts it (agree with Anish). *)
    Game.start_game seed
  with
  | End_of_file -> print_endline "\nInput ended. Exiting game."
  | error ->
      prerr_endline ("An unexpected error occurred: " ^ Printexc.to_string error);
      exit 1
