#use "corrige.ml";;

let m0 = {n_etats = 3; n_lettres = 2;
  delta = fun q x -> [|[|1;1|];[|0;2|];[|0;2|]|].(q).(x)}
let m1 = {n_etats = 2; n_lettres = 1; delta = fun q _ -> 1 - q}
let m2 = {n_etats = 4; n_lettres = 4;
  delta = fun q x -> [|[|1;0;3;2|];[|1;0;1;0|];[|2;3;0;1|];[|2;3;2;3|]|].(q).(x)}
let v0 = [| [(0,1);(3,0);(2,1);(1,0)]; [(1,0);(2,0)];
  [(1,1);(3,1);(4,1)]; [(2,0)]; [(1,0);(5,1)]; [(1,0)] |]
let echoue f = try f (); false with Failure _ -> true

let () =
  (* 1. Lecture d'un mot, y compris le mot vide. *)
  assert (delta_etoile m0 2 [] = 2 && delta_etoile m0 0 [1;0] = 0);
  (* 2. Les exemples de synchronisation du sujet. *)
  assert (est_synchronisant m0 [1;0] && est_synchronisant m0 [1;1]);
  assert (not (est_synchronisant m0 []) && not (est_synchronisant m1 [0;0;0]));
  assert (est_synchronisant m2 [0;2;0]);
  (* 3. Arrêt au premier contre-exemple. *)
  let appels = ref 0 in
  let m = {n_etats = 10; n_lettres = 1;
    delta = fun q _ -> incr appels; q} in
  assert (not (est_synchronisant m [0]) && !appels = 2);
  (* 4. File pleine, tour circulaire et extraction en ordre FIFO. *)
  let f = {tab = Array.make 2 0; deb = 0; fin = 0; vide = true} in
  ajoute f 4; ajoute f 5;
  assert (echoue (fun () -> ajoute f 6));
  assert (retire f = 4); ajoute f 6;
  assert (retire f = 5 && retire f = 6 && f.vide);
  assert (echoue (fun () -> ignore (retire f)));
  (* 5. Une capacité nulle refuse l'insertion. *)
  let vide = {tab = [||]; deb = 0; fin = 0; vide = true} in
  assert (echoue (fun () -> ajoute vide 0));
  (* 6. Distances et reconstruction d'un plus court chemin. *)
  let c,d,p = accessibles v0 [0] in
  assert (c = 0 && d = [|0;1;1;1;2;3|]);
  assert (chemin 0 p = [] && chemin 5 p = [1;1;1]);
  (* 7. Sources multiples, sommet inaccessible et graphe vide. *)
  let c,d,p = accessibles [|[(1,0)]; []; []|] [0;1] in
  assert (c = 1 && d = [|0;0;-1|] && p.(0) = Rien && p.(1) = Rien);
  assert (echoue (fun () -> ignore (chemin 2 p)));
  assert (accessibles [||] [] = (0,[||],[||]));
  (* 8. Conversions et transitions des ensembles, singleton ou paire. *)
  for n = 1 to 6 do
    for e = 0 to n * (n + 1) / 2 - 1 do
      assert (set_to_nb n (nb_to_set n e) = e)
    done
  done;
  assert (nb_to_set 3 (delta2 m0 (set_to_nb 3 (Deux (1,2))) 0) = Un 0);
  assert (nb_to_set 3 (delta2 m0 (set_to_nb 3 (Deux (0,1))) 1) = Deux (1,2));
  assert (nb_to_set 3 (delta2 m0 (set_to_nb 3 (Un 0)) 1) = Un 1);
  (* 9. Tous les arcs inversés sont conservés une fois, sans arcs parasites. *)
  let v = retourne_machine m0 in
  let total = Array.fold_left (fun acc arcs -> acc + List.length arcs) 0 v in
  assert (total = 12);
  Array.iteri (fun arrivee arcs ->
    List.iter (fun (depart,x) -> assert (delta2 m0 depart x = arrivee)) arcs) v;
  for q = 0 to 5 do
    for x = 0 to 1 do
      assert (List.mem (q,x) v.(delta2 m0 q x))
    done
  done;
  (* 10. Critère d'existence positif, négatif et cas d'un seul état. *)
  assert (existe_synchronisant m0 && existe_synchronisant m2);
  assert (not (existe_synchronisant m1));
  assert (existe_synchronisant {n_etats = 1; n_lettres = 1; delta = fun _ _ -> 0});
  print_endline "Centrale 2017 : 10 groupes de tests reussis."
