type automate = int * (int * int) array * bool array
type morphisme = int array

let a2 : automate = (2, [|(0, 1); (1, 0)|], [|false; true|])

let numero n liste =
  let t = Array.make n (-1) in
  let rec aux position = function
    | [] -> ()
    | q :: suite ->
        t.(q) <- position;
        aux (position + 1) suite
  in
  aux 0 liste;
  t

(* BEGIN etats_accessibles *)
let etats_accessibles (n, delta, f) =
  let vus = Array.make n false in
  let resultat = ref [] in
  let rec visiter q =
    if not vus.(q) then begin
      vus.(q) <- true;
      resultat := q :: !resultat;
      let succ_a, succ_b = delta.(q) in
      visiter succ_a;
      visiter succ_b
    end
  in
  visiter 0;
  let rec renverser acc = function (* ou List.rev *)
    | [] -> acc
    | q :: suite -> renverser (q :: acc) suite
  in
  renverser [] !resultat
(* END etats_accessibles *)

let partie_accessible ((n, delta, f) as aut) =
  let accessibles = etats_accessibles aut in
  let num = numero n accessibles in
  let n' = List.length accessibles in
  let delta' = Array.make n' (0, 0) in
  let f' = Array.make n' false in
  let copier q =
    let succ_a, succ_b = delta.(q) in
    delta'.(num.(q)) <- (num.(succ_a), num.(succ_b));
    f'.(num.(q)) <- f.(q)
  in
  List.iter copier accessibles;
  (n', delta', f')

let existe_morphisme (n, delta, f) (n', delta', f') =
  let phi = Array.make n (-1) in
  let possible = ref true in
  let rec visiter q q' =
    if !possible then begin
      if phi.(q) <> -1 then begin
        if phi.(q) <> q' then possible := false
      end else if f.(q) <> f'.(q') then
        possible := false
      else begin
        phi.(q) <- q';
        let qa, qb = delta.(q) in
        let qa', qb' = delta'.(q') in
        visiter qa qa';
        visiter qb qb'
      end
    end
  in
  visiter 0 0;
  (!possible, phi)

let produit (n, delta, f) (n', delta', f') =
  let delta_prod = Array.make (n * n') (0, 0) in
  let f_prod = Array.make (n * n') false in
  for q = 0 to n - 1 do
    for q' = 0 to n' - 1 do
      let qa, qb = delta.(q) in
      let qa', qb' = delta'.(q') in
      let k = q + n * q' in
      delta_prod.(k) <- (qa + n * qa', qb + n * qb');
      f_prod.(k) <- f.(q) && f'.(q')
    done
  done;
  (n * n', delta_prod, f_prod)

let renomme t =
  let n = Array.length t in
  if n = 0 then [||]
  else begin
    let maximum = ref t.(0) in
    for i = 1 to n - 1 do
      maximum := max !maximum t.(i)
    done;
    let code = Array.make (!maximum + 1) (-1) in
    let resultat = Array.make n 0 in
    let prochain = ref 0 in
    for i = 0 to n - 1 do
      let valeur = t.(i) in
      if code.(valeur) = -1 then begin
        code.(valeur) <- !prochain;
        incr prochain
      end;
      resultat.(i) <- code.(valeur)
    done;
    resultat
  end

let relation phi psi =
  let n = Array.length phi in
  let eta = Array.make n (-1) in
  let rec visiter p classe =
    if eta.(p) = -1 then begin
      eta.(p) <- classe;
      for q = 0 to n - 1 do
        if phi.(p) = phi.(q) || psi.(p) = psi.(q) then
          visiter q classe
      done
    end
  in
  let prochaine = ref 0 in
  for p = 0 to n - 1 do
    if eta.(p) = -1 then begin
      visiter p !prochaine;
      incr prochaine
    end
  done;
  eta

let table_de_predecesseurs (n, delta, f) =
  let pred = Array.make_matrix n n [] in
  for p = 0 to n - 1 do
    for q = 0 to n - 1 do
      let pa, pb = delta.(p) in
      let qa, qb = delta.(q) in
      pred.(pa).(qa) <- (p, q) :: pred.(pa).(qa);
      pred.(pb).(qb) <- (p, q) :: pred.(pb).(qb)
    done
  done;
  let d = Array.make_matrix n n false in
  let rec visiter (p, q) =
    if not d.(p).(q) then begin
      d.(p).(q) <- true;
      List.iter visiter pred.(p).(q)
    end
  in
  for p = 0 to n - 1 do
    for q = 0 to n - 1 do
      if f.(p) <> f.(q) then visiter (p, q)
    done
  done;
  d

let reduit aut =
  let ((n, delta, f) as accessible) = partie_accessible aut in
  let d = table_de_predecesseurs accessible in
  let classe = Array.make n (-1) in
  let representant = Array.make n 0 in
  let nombre = ref 0 in
  for p = 0 to n - 1 do
    if classe.(p) = -1 then begin
      representant.(!nombre) <- p;
      for q = p to n - 1 do
        if not d.(p).(q) then classe.(q) <- !nombre
      done;
      incr nombre
    end
  done;
  let delta' = Array.make !nombre (0, 0) in
  let f' = Array.make !nombre false in
  for k = 0 to !nombre - 1 do
    let p = representant.(k) in
    let pa, pb = delta.(p) in
    delta'.(k) <- (classe.(pa), classe.(pb));
    f'.(k) <- f.(p)
  done;
  (!nombre, delta', f')
