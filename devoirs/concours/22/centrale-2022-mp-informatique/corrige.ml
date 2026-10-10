(* Les régions nommées sont affichées directement dans le sujet Typst. *)
(* BEGIN automate *)
type automate = {
  nb : int;
  init : int list;
  final : int list;
  trans : (int * char * int) list
}
(* END automate *)

(* BEGIN a1 *)
let a1 = {
  nb = 3; init = [0]; final = [2];
  trans = [(0, 'a', 0); (0, 'a', 1); (0, 'b', 0);
           (1, 'b', 2); (2, 'a', 2)]
}
(* END a1 *)

(* BEGIN Q4 *)
let transpose a =
  { nb = a.nb; init = a.final; final = a.init;
    trans = List.map (fun (p, c, q) -> (q, c, p)) a.trans }
(* END Q4 *)

(* BEGIN Q6 *)
let palindrome s =
  let n = String.length s in
  let rec teste i =
    i >= n / 2 || (s.[i] = s.[n - 1 - i] && teste (i + 1))
  in
  teste 0
(* END Q6 *)

(* BEGIN Q13 *)
let a2 = {
  nb = 4; init = [0]; final = [3];
  trans = [(0, 'b', 0); (0, 'a', 1); (1, 'b', 0);
           (0, 'b', 2); (2, 'a', 3)]
}
(* END Q13 *)

(* BEGIN Q17 *)
let rec supprimer = function
  | [] -> []
  | x :: xs ->
      if List.mem x xs then supprimer xs
      else x :: supprimer xs
(* END Q17 *)

(* BEGIN pow *)
let pow = Array.make 21 1
let () =
  for i = 1 to 20 do
    pow.(i) <- pow.(i - 1) * 2
  done
(* END pow *)

(* BEGIN Q19 *)
let est_dans q k = (k / pow.(q)) mod 2 = 1
(* END Q19 *)

(* BEGIN Q20 *)
let numero l =
  let rec ajoute k = function
    | [] -> k
    | q :: qs ->
        ajoute (if est_dans q k then k else k + pow.(q)) qs
  in
  ajoute 0 l
(* END Q20 *)

(* BEGIN Q21 *)
let rec intersecte l k =
  match l with
  | [] -> false
  | q :: qs -> est_dans q k || intersecte qs k
(* END Q21 *)

(* BEGIN Q22 *)
let etat_suivant k transitions =
  let ajoute q x = if est_dans q x then x else x + pow.(q) in
  let rec parcours ka kb = function
    | [] -> (ka, kb)
    | (p, c, q) :: ts ->
        if not (est_dans p k) then parcours ka kb ts
        else if c = 'a' then parcours (ajoute q ka) kb ts
        else parcours ka (ajoute q kb) ts
  in
  parcours 0 0 transitions
(* END Q22 *)

(* BEGIN Q23 *)
let rec cherche k = function
  | [] -> -1
  | (x, v) :: xs -> if x = k then v else cherche k xs
(* END Q23 *)

(* BEGIN Q24 *)
let determinise a =
  let depart = numero a.init in
  let noms = ref [(depart, 0)] in
  let nombre = ref 1 in
  let attente = ref [depart] in
  let transitions = ref [] in
  let finaux = ref [] in
  let nom k =
    let v = cherche k !noms in
    if v <> -1 then v
    else begin
      let v = !nombre in
      incr nombre;
      noms := (k, v) :: !noms;
      attente := k :: !attente;
      v
    end
  in
  while !attente <> [] do
    match !attente with
    | [] -> ()
    | k :: suite ->
        attente := suite;
        let v = cherche k !noms in
        if intersecte a.final k then finaux := v :: !finaux;
        let ka, kb = etat_suivant k a.trans in
        let va = nom ka in
        let vb = nom kb in
        transitions := (v, 'a', va) :: (v, 'b', vb) :: !transitions
  done;
  { nb = !nombre; init = [0]; final = !finaux; trans = !transitions }
(* END Q24 *)

(* BEGIN Q29 *)
let minimal a = determinise (transpose (determinise (transpose a)))
(* END Q29 *)

(* BEGIN exprat *)
type exprat =
  | Vide
  | Epsilon
  | Lettre of char
  | Union of exprat * exprat
  | Concat of exprat * exprat
  | Etoile of exprat
(* END exprat *)

(* BEGIN Q30 *)
let rec lettre = function
  | Vide | Epsilon -> 0
  | Lettre _ -> 1
  | Union (e, f) | Concat (e, f) -> lettre e + lettre f
  | Etoile e -> lettre e
(* END Q30 *)

(* BEGIN Q31 *)
let rec est_vide = function
  | Vide -> true
  | Epsilon | Lettre _ | Etoile _ -> false
  | Union (e, f) -> est_vide e && est_vide f
  | Concat (e, f) -> est_vide e || est_vide f
(* END Q31 *)

(* BEGIN su *)
let su = function
  | Union (Vide, e) | Union (e, Vide) -> e
  | e -> e
(* END su *)

(* BEGIN Q32 *)
let se = function
  | Etoile Vide | Etoile Epsilon -> Epsilon
  | Etoile (Etoile e) -> Etoile e
  | e -> e
(* END Q32 *)

(* BEGIN Q34 *)
let sc = function
  | Concat (Vide, _) | Concat (_, Vide) -> Vide
  | Concat (Epsilon, e) | Concat (e, Epsilon) -> e
  | e -> e

let rec simplifie = function
  | Union (e, f) -> su (Union (simplifie e, simplifie f))
  | Concat (e, f) -> sc (Concat (simplifie e, simplifie f))
  | Etoile e -> se (Etoile (simplifie e))
  | e -> e
(* END Q34 *)

(* BEGIN mat *)
type mat = exprat array array
(* END mat *)

(* BEGIN Q35 *)
let somme a b =
  let n = Array.length a in
  let p = Array.length a.(0) in
  Array.init n (fun i -> Array.init p (fun j -> Union (a.(i).(j), b.(i).(j))))
(* END Q35 *)

(* BEGIN Q36 *)
let produit a b =
  let n = Array.length a in
  let p = Array.length b in
  let q = Array.length b.(0) in
  let c = Array.make_matrix n q Vide in
  for i = 0 to n - 1 do
    for j = 0 to q - 1 do
      for k = 0 to p - 1 do
        c.(i).(j) <- Union (c.(i).(j), Concat (a.(i).(k), b.(k).(j)))
      done
    done
  done;
  c
(* END Q36 *)

(* Fonctions fournies par l'énoncé, implémentées pour exécuter le corrigé. *)
let decouper m n1 n2 =
  let bloc i0 j0 n p =
    Array.init n (fun i -> Array.init p (fun j -> m.(i0 + i).(j0 + j)))
  in
  (bloc 0 0 n1 n1, bloc 0 n1 n1 n2,
   bloc n1 0 n2 n1, bloc n1 n1 n2 n2)

let recoller a b c d =
  let n1 = Array.length a and n2 = Array.length d in
  Array.init (n1 + n2) (fun i ->
    Array.init (n1 + n2) (fun j ->
      if i < n1 then
        if j < n1 then a.(i).(j) else b.(i).(j - n1)
      else if j < n1 then c.(i - n1).(j)
      else d.(i - n1).(j - n1)))

(* BEGIN Q41 *)
let rec etoile m =
  let n = Array.length m in
  if n = 1 then [|[|Etoile m.(0).(0)|]|]
  else begin
    let n1 = n / 2 in
    let a, b, c, d = decouper m n1 (n - n1) in
    let sa = etoile a in
    let sd = etoile d in
    let sab = produit sa b in
    let sdc = produit sd c in
    let ap = etoile (somme a (produit b sdc)) in
    let dp = etoile (somme d (produit c sab)) in
    recoller ap (produit sab dp) (produit sdc ap) dp
  end
(* END Q41 *)

(* BEGIN Q43 *)
let langage a =
  if a.nb = 0 then Vide
  else begin
    let m = Array.make_matrix a.nb a.nb Vide in
    List.iter (fun (i, c, j) ->
      m.(i).(j) <- Union (m.(i).(j), Lettre c)) a.trans;
    let fermeture = etoile m in
    let resultat = ref Vide in
    List.iter (fun i ->
      List.iter (fun j ->
        resultat := Union (!resultat, fermeture.(i).(j))) a.final) a.init;
    !resultat
  end
(* END Q43 *)
