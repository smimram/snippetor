let fname = ref ""
type mode = Agda | OCaml
let mode = ref OCaml

let () =
  let filename s =
    fname := s;
    match Filename.extension s with
      | ".ml" -> mode := OCaml
      | ".agda" -> mode := Agda
      | _ -> ()
  in
  Arg.parse
    [
      "--agda", Arg.Unit (fun () -> mode := Agda), "Agda mode.";
      "--ocaml", Arg.Unit (fun () -> mode := OCaml), "OCaml mode."
    ]
    filename "snippetor [options] file";
  if !fname = "" then
    (
      Printf.eprintf "Please provide a file name.\n%!";
      exit 1
    )

module RE = struct
  let regexp s =
    let s =
      match !mode with
      | Agda -> "[ ]*-- !?" ^ s
      | OCaml -> "[ ]*(\\* !?" ^ s
    in
    Str.regexp s

  let hide = regexp "HIDE[ ]*\\([0-9]*\\)"

  let indent = regexp "INDENT[ ]*\\([-]?[0-9]+\\)"

  let start = regexp "BEGIN[ ]*\\([-a-zA-Z0-9]+\\)"

  let stop = regexp "END[ ]*\\([-a-zA-Z0-9]*\\)"
end

let () =
  let fname = !fname in
  Printf.printf "Preprocessing %s... %!" fname;
  let ic = open_in fname in
  let outdir = "include/" in
  let ocni = open_out (outdir^fname^".noimport") in
  let ocni_first = ref true in
  let ocs = ref ["include", open_out (outdir^fname); "include", open_out (outdir^fname^".include")] in
  let output l =
    List.iter (fun (_,oc) -> output_string oc (l^"\n")) !ocs;
    if String.length l < 11 || String.sub l 0 11 <> "open import" then
      if not (!ocni_first && l = "") then
        (
          ocni_first := false;
          output_string ocni (l^"\n")
        )
  in
  let hide = ref 0 in
  let indent = ref 0 in
  (
    try
      while true do
        let l = input_line ic in
        if Str.string_match RE.hide l 0 then
          let n = Str.matched_group 1 l in
          let n = if n = "" then 1 else int_of_string n in
          hide := n
        else if Str.string_match RE.indent l 0 then
          let n = Str.matched_group 1 l in
          let n = int_of_string n in
          indent := n
        else if Str.string_match RE.start l 0 then
          let s = Str.matched_group 1 l in
          let oc = open_out (outdir^fname^"."^s) in
          ocs := (s, oc) :: !ocs
        else if Str.string_match RE.stop l 0 then
          let s = Str.matched_group 1 l in
          indent := 0;
          if s = "" then ocs := List.tl !ocs
          else ocs := List.filter (fun (s',_) -> s' <> s) !ocs
        else if !hide > 0 then decr hide else
          let l =
            if !indent = 0 then l
            else if !indent > 0 then String.make !indent ' ' ^ l
            else if String.length l >= - !indent then String.sub l (- !indent) (String.length l + !indent)
            else ""
          in
          output l
      done
    with
    | End_of_file -> ()
  );
  close_in ic;
  List.iter (fun (_,oc) -> close_out oc) !ocs;
  Printf.printf "done.\n%!"
