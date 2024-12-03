let remove_last lst =
  match List.rev lst with
  | [] -> []
  | _ :: xs -> List.rev xs
;;

let read_all file =
  let ic = Stdlib.open_in file in
  let len = Stdlib.in_channel_length ic in
  let out = Stdlib.really_input_string ic len |> String.trim in
  close_in ic;
  out
;;

let read_lines file =
  let ic = Stdlib.open_in file in
  let len = Stdlib.in_channel_length ic in
  let out =
    Stdlib.really_input_string ic len
    |> String.trim
    |> String.split_on_char '\n'
  in
  close_in ic;
  out
;;

let rec _count acc t lst =
  match lst with
  | [] -> acc
  | x :: xs -> _count (if x = t then succ acc else acc) t xs
;;

(** counts occurrences of [t] in [lst] *)
let count lst t = _count 0 t lst

(** prints every value in [lst] using [print], returns [lst] making it usable in pipelines *)
let debug_list print lst =
  print_string "[\n";
  List.iter
    (fun x ->
      print_string "  ";
      print x;
      print_string ";\n")
    lst;
  print_string "]\n";
  lst
;;
