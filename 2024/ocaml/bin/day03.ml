let rec _find_muls str cur acc =
  if cur >= String.length str
  then acc
  else (
    let mstart = String.index_from str cur 'm' in
    let ms3 = mstart + 3 in
    let mul_str = String.sub str mstart ms3 in
    (* Printf.printf "cur: %d %d %s\n" cur ms3 mul_str; *)
    if mul_str = "mul("
    then (
      let comma_idx = String.index_from str ms3 ',' in
      let close_par = String.index_from str comma_idx ')' in
      (* Printf.printf "comma:%d close:%d\n" comma_idx close_par; *)
      let left =
        String.sub str (succ ms3) (comma_idx - succ ms3) |> int_of_string
      in
      let right =
        String.sub str (succ comma_idx) (close_par - succ comma_idx)
        |> int_of_string
      in
      _find_muls str (succ close_par) ((left, right) :: acc))
    else _find_muls str (succ cur) acc)
;;

let find_muls str = _find_muls str 0 []

let part_one () =
  let input = Advent.read_all "./input/day03" |> String.trim in
  input
  |> find_muls
  (* |> Advent.debug_list (fun x -> Printf.printf "(%d,%d)" (fst x) (snd x)) *)
  |> List.fold_left (fun acc pair -> acc + (fst pair * snd pair)) 0
  |> string_of_int
;;

let () =
  let res = part_one () in
  print_endline res
;;
