(* !BEGIN suc *)
let rec suc n =
  if n = 0 then 1 else 1 + suc (n-1)
(* !END *)

(* !BEGIN fact *)
let rec fact n =
  if n = 0 then 1 else n * fact (n - 1)
(* !END *)

let () =
  assert (fact 5 = 120)
