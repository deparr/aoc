let remove_last lst =
  match List.rev lst with
  | [] -> []
  | _ :: xs -> List.rev xs
;;

let read_all file =
  let ic = Stdlib.open_in file in
  let len = Stdlib.in_channel_length ic in
  let out = really_input_string ic len in
  close_in ic;
  out
;;

let read_lines file =
  let ic = Stdlib.open_in file in
  let len = Stdlib.in_channel_length ic in
  let out = String.split_on_char '\n' (Stdlib.really_input_string ic len) in
  close_in ic;
  remove_last out
;;

let print_int_list2 l r =
  List.iter2 (fun ln rn -> Printf.printf "%d %d\n" ln rn) l r
;;

let rec _count acc t lst =
  match lst with
  | [] -> acc
  | x :: xs -> _count (if x = t then succ acc else acc) t xs
;;

let count lst t = _count 0 t lst

