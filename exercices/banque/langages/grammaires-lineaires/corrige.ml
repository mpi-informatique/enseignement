(* BEGIN types *)
type regle = Vide | Prefixe of char * int | Suffixe of int * char
type grammaire = regle list array
(* END types *)

(* BEGIN reconnait *)
let reconnait (g : grammaire) s w =
  let m = Array.length g and n = String.length w in
  let d = Array.init m (fun _ ->
    Array.init (n + 1) (fun _ -> Array.make (n + 1) false)) in
  for longueur = 0 to n do
    for i = 0 to n - longueur do
      let j = i + longueur in
      let rec possible regles =
        match regles with
        | [] -> false
        | regle :: suite ->
            let convient = match regle with
              | Vide -> i = j
              | Prefixe (a, y) ->
                  i < j && w.[i] = a && d.(y).(i + 1).(j)
              | Suffixe (y, a) ->
                  i < j && w.[j - 1] = a && d.(y).(i).(j - 1)
            in
            if convient then true else possible suite
      in
      for x = 0 to m - 1 do
        d.(x).(i).(j) <- possible g.(x)
      done
    done
  done;
  d.(s).(0).(n)
(* END reconnait *)
