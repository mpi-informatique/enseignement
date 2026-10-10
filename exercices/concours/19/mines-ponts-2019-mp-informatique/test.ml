#use "corrige.ml";;
#use "tests.ml";;

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
