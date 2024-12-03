let rec extract_all_matches input regex start acc =
  try
    let _ = Str.search_forward regex input start in
    let l = Str.matched_group 1 input |> int_of_string in
    let r = Str.matched_group 2 input |> int_of_string in
    extract_all_matches input regex (Str.match_end ()) (acc + (l * r))
  with
  | Not_found -> acc
;;

let rec extract_all_matches2 input regex start acc enabled =
  try
    let _ = Str.search_forward regex input start in
    let func = Str.matched_group 1 input in
    let match_end = Str.match_end () in
    match String.sub func 0 3 with
    | "do(" -> extract_all_matches2 input regex match_end acc true
    | "don" -> extract_all_matches2 input regex match_end acc false
    | "mul" ->
      let l = Str.matched_group 2 input |> int_of_string in
      let r = Str.matched_group 3 input |> int_of_string in
      let prod = l * r in
      extract_all_matches2
        input
        regex
        match_end
        (if enabled then prod :: acc else acc)
        enabled
    | _ -> assert false
  with
  | Not_found -> acc
;;

let part_one () =
  let input = Advent.read_all "./input/day03" |> String.trim in
  let regexp = Str.regexp {|mul(\([0-9]+\),\([0-9]+\))|} in
  extract_all_matches input regexp 0 0 |> string_of_int
;;

let part_two () =
  let input = Advent.read_all "./input/day03" |> String.trim in
  let regexp = Str.regexp {|\(mul(\([0-9]+\),\([0-9]+\))\|do()\|don't()\)|} in
  extract_all_matches2 input regexp 0 [] true
  |> List.fold_left ( + ) 0
  |> string_of_int
;;

let () =
  let res = part_one () in
  let res2 = part_two () in
  print_endline res;
  print_endline res2
;;
