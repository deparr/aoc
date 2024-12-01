let _part_one () =
  let input = Advent.read_lines "./input/day01" in
  let split = List.map (String.split_on_char ' ') input in
  let ints = List.map (List.filter_map int_of_string_opt) split in
  let left = ints |> List.map (fun x -> List.nth x 0) |> List.sort compare in
  let right = ints |> List.map (fun x -> List.nth x 1) |> List.sort compare in

  let res =
    List.map2 ( - ) left right |> List.map Int.abs |> List.fold_left ( + ) 0
  in
  print_endline (string_of_int res)
;;

let part_two () = 
  let input = Advent.read_lines "./input/day01" in
  let split = List.map (String.split_on_char ' ') input in
  let ints = List.map (List.filter_map int_of_string_opt) split in
  let left = ints |> List.map (fun x -> List.nth x 0) |> List.sort compare in
  let right = ints |> List.map (fun x -> List.nth x 1) |> List.sort compare in
  let counts = left |> List.map (Advent.count right) in

  let res = List.map2 ( * ) left counts |> List.fold_left ( + ) 0 in
  print_endline (string_of_int res)
;;

let () = part_two ()
