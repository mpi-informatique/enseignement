#use "corrige.ml";;

let verifie message condition = if not condition then failwith message

let rec mots n =
  if n = 0 then [""]
  else "" :: List.concat_map (fun w -> ["a" ^ w; "b" ^ w]) (mots (n - 1))

let accepte a w =
  let etats = ref a.init in
  String.iter (fun c ->
    etats := List.sort_uniq compare
      (List.filter_map (fun (p, d, q) ->
        if c = d && List.mem p !etats then Some q else None) a.trans)) w;
  List.exists (fun q -> List.mem q a.final) !etats

let miroir s = String.init (String.length s) (fun i -> s.[String.length s - 1 - i])

let suivant a q c =
  match List.filter (fun (p, d, _) -> p = q && c = d) a.trans with
  | [(_, _, r)] -> r
  | _ -> failwith "Automate non déterministe ou incomplet"

(* Équivalence exacte de deux états déterministes par parcours du produit. *)
let equivalents a p b q =
  let vus = Hashtbl.create 16 in
  let rec explore = function
    | [] -> true
    | (p, q) :: suite when Hashtbl.mem vus (p, q) -> explore suite
    | (p, q) :: suite ->
        Hashtbl.add vus (p, q) ();
        (List.mem p a.final = List.mem q b.final) &&
        explore ((suivant a p 'a', suivant b q 'a') ::
                 (suivant a p 'b', suivant b q 'b') :: suite)
  in
  explore [p, q]

(* Sémantique indépendante des expressions : reconnaissance des sous-chaînes.
   Pour une étoile, ne consommer que des facteurs non vides assure la terminaison,
   y compris lorsque l'expression étoilée accepte epsilon. *)
let reconnait expression mot =
  let memo = Hashtbl.create 128 in
  let rec lit e i j =
    match Hashtbl.find_opt memo (e, i, j) with
    | Some b -> b
    | None ->
        let existe lo hi f =
          let rec boucle k = k <= hi && (f k || boucle (k + 1)) in
          boucle lo
        in
        let resultat = match e with
          | Vide -> false
          | Epsilon -> i = j
          | Lettre c -> j = i + 1 && mot.[i] = c
          | Union (a, b) -> lit a i j || lit b i j
          | Concat (a, b) -> existe i j (fun k -> lit a i k && lit b k j)
          | Etoile a -> i = j || existe (i + 1) j (fun k -> lit a i k && lit e k j)
        in
        Hashtbl.add memo (e, i, j) resultat;
        resultat
  in
  lit expression 0 (String.length mot)

let () =
  List.iter (fun w ->
    verifie "Palindromes" (palindrome w = (w = miroir w));
    verifie "Transposition" (accepte (transpose a1) w = accepte a1 (miroir w))) (mots 8);
  verifie "Palindromes longs" (palindrome (String.make 100000 'a'));
  verifie "Numéro avec doublons" (numero [1;5;2;5;2;5;2;2;1;2;1] = 38);
  verifie "Bit maximal" (est_dans 19 (numero [19;19]));
  verifie "Suppression" (List.sort compare (supprimer [2;1;2;3;1]) = [1;2;3]);
  verifie "Ensembles vides" (numero [] = 0 && not (intersecte [] 0));
  verifie "Successeurs, pas prédécesseurs"
    (etat_suivant 1 [(0,'a',1);(0,'a',1);(0,'b',2);(2,'a',3)] = (2,4));
  let vide = { nb=0; init=[]; final=[]; trans=[] } in
  verifie "Langage de l'automate vide" (langage vide = Vide);
  let det_vide = determinise vide in
  verifie "Déterminisé du langage vide" (det_vide.nb = 1 && det_vide.final = []);
  let boucles = { nb=1; init=[0]; final=[0]; trans=[0,'a',0;0,'b',0] } in
  verifie "État initial final et boucles" (determinise boucles = boucles);
  let a3 = determinise (transpose a2) in
  let a4 = minimal a2 in
  let table3 = { nb=5; init=[0]; final=[3;4]; trans=[
    0,'a',1;0,'b',2;1,'a',2;1,'b',3;2,'a',2;2,'b',2;
    3,'a',2;3,'b',4;4,'a',3;4,'b',4] } in
  let table4 = { nb=5; init=[0]; final=[4]; trans=[
    0,'a',1;0,'b',2;1,'a',3;1,'b',0;2,'a',4;2,'b',2;
    3,'a',3;3,'b',3;4,'a',3;4,'b',0] } in
  verifie "Table Q14" (a3.nb=5 && equivalents a3 0 table3 0);
  verifie "Table Q15" (a4.nb=5 && equivalents a4 0 table4 0);

  (* Tous les automates à deux états sur a,b, avec tous les choix I et F. *)
  let sous_ensemble masque = List.filter (fun q -> masque land (1 lsl q) <> 0) [0;1] in
  for masque = 0 to 255 do
    let transitions = ref [] in
    for i = 0 to 7 do
      if masque land (1 lsl i) <> 0 then
        transitions := (i / 4, (if (i / 2) mod 2 = 0 then 'a' else 'b'), i mod 2)
                       :: !transitions
    done;
    for init = 0 to 3 do
      for fin = 0 to 3 do
        let a = { nb=2; init=sous_ensemble init; final=sous_ensemble fin;
                  trans= !transitions } in
        let d = determinise a in
        List.iter (fun w -> verifie "Déterminisation" (accepte a w = accepte d w)) (mots 4);
        let m = minimal a in
        verifie "Brzozowski préserve le langage" (equivalents d 0 m 0);
        for p = 0 to m.nb - 1 do
          for q = p + 1 to m.nb - 1 do
            verifie "Brzozowski est minimal" (not (equivalents m p m q))
          done
        done
      done
    done
  done;

  let la = Lettre 'a' and lb = Lettre 'b' in
  let e = Union (Union (Concat (Etoile la, lb),
    Concat (la, Concat (lb, Concat (lb, Concat (la, Etoile (Union (la,Epsilon))))))), Vide) in
  verifie "Exemple Q30" (lettre e = 7);
  verifie "Langages vides" (est_vide (Concat (e,Vide)) && not (est_vide (Etoile Vide)));
  verifie "Étoile du vide" (se (Etoile Vide) = Epsilon);
  let rec en n = if n=0 then Vide else Concat (lb, en (n-1)) in
  verifie "Simplification E4" (simplifie (Union (la,en 4)) = la);
  let expressions = [Vide; Epsilon; e; Etoile Vide;
    Etoile (Etoile (Union (Vide,la))); Concat (Union (Vide,lb),Epsilon);
    Concat (Vide,Etoile la); Etoile (Union (Epsilon,Concat (la,lb)))] in
  List.iter (fun expression -> List.iter (fun w ->
    verifie "Simplification conserve le langage"
      (reconnait expression w = reconnait (simplifie expression) w)) (mots 4)) expressions;

  let rect_a = [|[|la; Epsilon; lb|]; [|Vide; lb; la|]|] in
  let rect_b = [|[|Epsilon; lb|];[|la; Vide|];[|lb; la|]|] in
  let rect_c = produit rect_a rect_b in
  List.iter (fun w -> for i=0 to 1 do for j=0 to 1 do
    let attendu = Union (Concat(rect_a.(i).(0),rect_b.(0).(j)),
      Union(Concat(rect_a.(i).(1),rect_b.(1).(j)),Concat(rect_a.(i).(2),rect_b.(2).(j)))) in
    verifie "Produit rectangulaire" (reconnait rect_c.(i).(j) w = reconnait attendu w)
  done done) (mots 3);

  (* Tailles paires, impaires et cas de base : comparer Conway à la simulation. *)
  Random.init 2022;
  let cas = ref [a1; a2; boucles; {nb=1;init=[0];final=[0];trans=[]}] in
  for n=1 to 5 do
    for _essai=1 to 3 do
      let transitions = ref [] in
      for i=0 to n-1 do for j=0 to n-1 do
        List.iter (fun c -> if Random.int 4=0 then
          transitions := (i,c,j):: !transitions) ['a';'b']
      done done;
      cas := {nb=n;init=[0];final=[n-1];trans= !transitions} :: !cas
    done
  done;
  List.iter (fun a ->
    let expression = langage a in
    List.iter (fun w -> verifie "Conway" (accepte a w = reconnait expression w)) (mots 4)) !cas;

  (* L'automate dessiné en Q45, avec E=0, bE=1, a=2, epsilon=3. *)
  let expression = Concat (Etoile (Union (Concat(la,lb),lb)),Concat(lb,la)) in
  List.iter (fun w -> verifie "Automate d'Antimirov Q45"
    (reconnait expression w = accepte a2 w)) (mots 8);
  Printf.printf "OCaml : 4096 automates, minimalité, palindromes, simplifications, matrices et Conway vérifiés.\n"
