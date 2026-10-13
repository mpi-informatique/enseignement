#use "corrige.ml";;
(* Vérifications communes au corrigé et aux copies. *)
(* BEGIN verifications *)
let verifie message condition = if not condition then failwith message
let a1 = (2, [|(1,1); (0,0)|], [|false;true|])
let a2_reference = (2, [|(0,1); (1,0)|], [|false;true|])
let a3 = (3, [|(1,2); (1,2); (2,1)|], [|false;false;true|])
let a4 = (4, [|(1,2); (0,3); (3,0); (2,1)|], [|false;false;true;true|])
(* Ordre P,O,Q,R,S,T de la figure 6 ; P est initial. *)
let a6 = (6, [|(0,2); (0,5); (3,1); (2,4); (5,4); (3,0)|],
             [|true;true;false;false;false;false|])

(* Oracle indépendant : comparer les langages depuis deux états par
   parcours du produit vers l'avant, jusqu'à un désaccord de finalité. *)
let equivalents (_, d, f) p (_, d', f') q =
  let vus = Hashtbl.create 16 in
  let rec visiter = function
    | [] -> true
    | (p,q) :: suite when Hashtbl.mem vus (p,q) -> visiter suite
    | (p,q) :: suite ->
        Hashtbl.add vus (p,q) ();
        let pa,pb = d.(p) and qa,qb = d'.(q) in
        f.(p) = f'.(q) && visiter ((pa,qa) :: (pb,qb) :: suite)
  in visiter [p,q]

let est_morphisme (n,d,f) (m,d',f') phi =
  let image = Array.make m false in
  let ok = ref (Array.length phi = n && phi.(0) = 0) in
  for p = 0 to n - 1 do
    let q = phi.(p) in
    if q < 0 || q >= m then ok := false
    else begin
      image.(q) <- true;
      let pa,pb = d.(p) and qa,qb = d'.(q) in
      if f.(p) <> f'.(q) || phi.(pa) <> qa || phi.(pb) <> qb then ok := false
    end
  done;
  !ok && Array.for_all (fun x -> x) image

let test_a2 a2 =
  verifie "automate a2" (a2 = a2_reference)

let test_numero numero =
  let liste = [3;2;0;3] in
  let resultat = numero 5 liste in
  verifie "numero" (resultat.(1) = -1 && resultat.(4) = -1 &&
    List.nth liste resultat.(0) = 0 && List.nth liste resultat.(2) = 2 &&
    List.nth liste resultat.(3) = 3 && numero 0 [] = [||])

let test_etats_accessibles etats_accessibles =
  verifie "ordre DFS" (etats_accessibles a6 = [0;2;3;4;5;1])

let test_partie_accessible partie_accessible =
  let trou = (4, [|(2,2);(1,1);(3,0);(3,2)|], [|false;true;false;true|]) in
  let attendu = (3, [|(1,1);(2,0);(2,1)|], [|false;false;true|]) in
  verifie "partie accessible" (partie_accessible trou = attendu)

let test_existe_morphisme existe_morphisme =
  let ok,phi = existe_morphisme a3 a2_reference in
  verifie "morphisme" (ok && est_morphisme a3 a2_reference phi);
  let non1,_ = existe_morphisme a1 a2_reference in
  let non2,_ = existe_morphisme (1,[|(0,0)|],[|true|]) (1,[|(0,0)|],[|false|]) in
  verifie "absence de morphisme" (not non1 && not non2)

let test_produit etats_accessibles produit =
  let prod = produit a3 a4 in
  verifie "produit" (List.length (etats_accessibles prod) = 5 &&
    equivalents prod 0 a2_reference 0)

let test_renomme renomme =
  verifie "renomme" (renomme [|4;4;5;0;4;5|] = [|0;0;1;2;0;1|] &&
    renomme [||] = [||])

let test_relation relation =
  verifie "relation" (relation [|0;1;1;2;2|] [|0;0;1;2;3|] = [|0;0;0;1;1|])

let test_table_de_predecesseurs table_de_predecesseurs =
  let contre_exemple = (2,[|(1,1);(1,1)|],[|false;true|]) in
  verifie "sens des prédécesseurs"
    (table_de_predecesseurs contre_exemple = [|[|false;true|];[|true;false|]|]);
  let d = table_de_predecesseurs a6 in
  for p = 0 to 5 do
    for q = 0 to 5 do
      verifie "table exacte" (d.(p).(q) = not (equivalents a6 p a6 q))
    done
  done

let test_reduit reduit etats_accessibles =
  let verifie_reduction aut taille =
    let ((n,_,_) as minimal) = reduit aut in
    verifie "nombre minimal d'états" (n = taille);
    verifie "conservation exacte du langage" (equivalents aut 0 minimal 0);
    verifie "accessibilité" (List.length (etats_accessibles minimal) = n);
    for p = 0 to n - 1 do
      for q = p + 1 to n - 1 do
        verifie "états distincts distinguables" (not (equivalents minimal p minimal q))
      done
    done
  in
  verifie_reduction a6 3;
  let trou = (4, [|(2,2);(1,1);(3,0);(3,2)|], [|false;true;false;true|]) in
  verifie_reduction trou 3;
  verifie_reduction (3,[|(1,2);(2,0);(0,1)|],[|false;false;false|]) 1;
  verifie_reduction (3,[|(1,2);(2,0);(0,1)|],[|true;true;true|]) 1
(* END verifications *)
;;

let () =
  test_a2 a2;
  test_numero numero;
  test_etats_accessibles etats_accessibles;
  test_partie_accessible partie_accessible;
  test_existe_morphisme existe_morphisme;
  test_produit etats_accessibles produit;
  test_renomme renomme;
  test_relation relation;
  test_table_de_predecesseurs table_de_predecesseurs;
  test_reduit reduit etats_accessibles;
  print_endline "Mines-Ponts 2019 : 10 groupes de tests réussis."
