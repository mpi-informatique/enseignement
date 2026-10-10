#use "corrige.ml";;

let equilibre = [| [Vide; Prefixe ('a', 1)]; [Suffixe (0, 'b')] |]
let ambigu = [| [Vide; Prefixe ('a', 0); Suffixe (0, 'a')] |]
let palindromes = [|
  [Vide; Prefixe ('a', 1); Prefixe ('b', 2)];
  [Vide; Suffixe (0, 'a')];
  [Vide; Suffixe (0, 'b')]
|]

let cas = [
  ("mot vide", equilibre, 0, "", true);
  ("lettre isolee", equilibre, 0, "a", false);
  ("lettre finale isolee", equilibre, 0, "b", false);
  ("imbrication", equilibre, 0, "aaabbb", true);
  ("comptages differents", equilibre, 0, "aabbb", false);
  ("ordre des lettres", equilibre, 0, "abab", false);
  ("grammaire ambigue", ambigu, 0, "aaaa", true);
  ("cycle sans terminaison", [| [Prefixe ('a', 0)] |], 0, "aa", false);
  ("axiome non nul et variable sterile", [| []; [Vide] |], 1, "", true);
  ("palindrome pair", palindromes, 0, "abba", true);
  ("palindrome impair", palindromes, 0, "aba", true);
  ("non palindrome", palindromes, 0, "abb", false)
]

let rec verifier = function
  | [] -> ()
  | (nom, g, s, w, attendu) :: suite ->
      if reconnait g s w <> attendu then failwith nom;
      verifier suite

let () =
  verifier cas;
  print_endline "Grammaires lineaires : 12 tests reussis."
