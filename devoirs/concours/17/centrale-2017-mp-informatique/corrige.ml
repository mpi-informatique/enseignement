type lettre = int
type mot = lettre list
type etat = int
type machine = {n_etats : int; n_lettres : int; delta : etat -> lettre -> etat}
type 'a file = {tab : 'a array; mutable deb : int; mutable fin : int; mutable vide : bool}
type arc = Rien | Vide | Arc of etat * lettre
type un_ou_deux = Un of int | Deux of int * int

(* Codage des singletons, puis des paires : utilisé seulement par les tests.
   L'énoncé suppose les conversions disponibles en temps constant. *)
let set_to_nb n = function
  | Un i -> i
  | Deux (i, j) -> n + i * (2 * n - i - 1) / 2 + j - i - 1
let nb_to_set n q =
  if q < n then Un q else
  let rec ligne i k =
    let taille = n - i - 1 in
    if k < taille then Deux (i, i + 1 + k) else ligne (i + 1) (k - taille)
  in ligne 0 (q - n)

let rec delta_etoile m q w =
  match w with
  | [] -> q
  | x :: xs -> delta_etoile m (m.delta q x) xs

let est_synchronisant m w =
  let candidat = delta_etoile m 0 w in
  let q = ref 1 in
  while !q < m.n_etats && delta_etoile m !q w = candidat do
    incr q
  done;
  !q = m.n_etats

let ajoute f x =
  if Array.length f.tab = 0 || (f.deb = f.fin && not f.vide) then failwith "file pleine";
  f.tab.(f.fin) <- x;
  f.fin <- (f.fin + 1) mod (Array.length f.tab);
  f.vide <- false

let retire f =
  if f.vide then failwith "file vide";
  let resultat = f.tab.(f.deb) in
  f.deb <- (f.deb + 1) mod (Array.length f.tab);
  if f.deb = f.fin then f.vide <- true;
  resultat

let accessibles graphe ens =
  (* initialisation *)
  let n = Array.length graphe in
  let f = {tab = Array.make n 0; deb = 0; fin = 0; vide = true} in
  let inf = -1 in
  let d = Array.make n inf in
  let p = Array.make n Vide in
  let c = ref n in

  (* boucle for *)
  let initialise s =
    ajoute f s;
    d.(s) <- 0;
    p.(s) <- Rien;
    c := !c - 1 in
  List.iter initialise ens;

  (* boucle while *)
  while not f.vide do
    let s = retire f in
    let traite_arc (s', y) =
      if d.(s') = inf then begin
        d.(s') <- d.(s) + 1;
        p.(s') <- Arc (s, y);
        ajoute f s';
        decr c
      end in
    List.iter traite_arc graphe.(s);
  done;

  !c, d, p

let chemin s p =
  let rec aux s chemin =
  match p.(s) with
  | Vide -> failwith "pas de chemin"
  | Rien -> chemin
  | Arc (s', x) -> aux s' (x :: chemin) in
  aux s []

let delta2 m e x =
  let n = m.n_etats in
  match nb_to_set n e with
  | Un i -> set_to_nb n (Un (m.delta i x))
  | Deux (i, j) ->
    let ei = m.delta i x in
    let ej = m.delta j x in
    if ei = ej then set_to_nb n (Un ei)
    else set_to_nb n (Deux (min ei ej, max ei ej))

let retourne_machine m =
  let n = m.n_etats in
  let ntilde = n * (n + 1) / 2 in
  let v = Array.make ntilde [] in
  for q = 0 to ntilde - 1 do
    for x = 0 to m.n_lettres - 1 do
      let q' = delta2 m q x in
      v.(q') <- (q, x) :: v.(q')
    done
  done;
  v

let singletons n =
  let rec aux k =
    if k = n then []
    else set_to_nb n (Un k) :: aux (k + 1) in
  aux 0

let existe_synchronisant m =
  let c, _, _ = accessibles (retourne_machine m) (singletons m.n_etats) in
  c = 0
