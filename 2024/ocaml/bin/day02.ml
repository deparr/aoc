let rec _is_safe prev lst sign =
  match lst with
  | [] -> true
  | x :: xs when sign = 0 ->
    let sign_to_match = x - prev in
    let diff = Int.abs sign_to_match in
    diff >= 1 && diff <= 3 && _is_safe x xs sign_to_match
  | x :: xs ->
    let diff = x - prev in
    let diff_abs = Int.abs diff in
    Bool.equal (sign < 0) (diff < 0)
    && diff_abs >= 1
    && diff_abs <= 3
    && _is_safe x xs diff
;;

let is_safe = function
  | [] -> true
  | x :: xs -> _is_safe x xs 0
;;

let part_one () =
  let input = Advent.read_lines "./input/day02" in
  let ints =
    List.map
      (fun x -> List.map int_of_string (String.split_on_char ' ' x))
      input
  in
  let count =
    ints
    |> List.fold_left (fun acc report -> acc + (Bool.to_int (is_safe report)))  0
  in
  string_of_int count
;;


let _part_two () =
  let input = Advent.read_lines "./input/day02" in
  let _ints =
    List.map
      (fun x -> List.map int_of_string (String.split_on_char ' ' x))
      input
  in
  String.trim "todo: do part two"
;;

let () =
  let res = part_one () in
  print_string res
;;
