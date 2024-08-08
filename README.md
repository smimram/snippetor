Snippettor
==========

Snippettor is a tool to extract excerpts from code (for now [OCaml](https://ocaml.org/) and [Agda](https://wiki.portal.chalmers.se/agda/) are supported). I use it to include portions of code in my LaTeX files
(e.g. [this course](http://pp.mimram.fr/)), while ensuring that it is compiling.

Usage
-----

In order to specify snippets in OCaml code, you should enclose them with comments `(* BEGIN name *)` and `(* END *)` where `name` is the name you want to give to the snippet. For instance, consider the following file [`example.ml`](example/example.ml):

```ocaml
(* BEGIN suc *)
let rec suc n =
  if n = 0 then 1 else 1 + suc (n-1)
(* END *)

(* BEGIN fact *)
let rec fact n =
  if n = 0 then 1 else n * fact (n - 1)
(* END *)

let () =
  assert (fact 5 = 120)
```

If you run the command

```sh
snippetor example.ml
```

it will produce the following files in the `include` directory:

- `example.ml.suc` which contains the code for the `suc` function,
- `example.ml.fact` which contains the code for the `fact` function,
- `example.ml` which contains the code without the comments specific to
  snippetor.

The usage for Agda files is similar, excepting that comments are of the form `-- BEGIN name` and `-- END`.

More options
------------

- You can use comments of the form `(* INDENT -2 *)` in order to unindent the following block of code by two blanks.
- You can use `(* HIDE *)` to hide the following line within a snippet (and `(* HIDE 5 *)` to hide the following 5 lines).
