#import "/lib/exercice.typ": feuille
#import "/exercices/banque/langages/langages-locaux-glushkov.typ": ex as locaux
#import "/exercices/banque/langages/ccp-sujet0-langages-automates.typ": ex as ccp
#import "/exercices/banque/langages/stabilite-langages-reguliers.typ": ex as stabilite
#import "/exercices/banque/langages/kleene-programmation-dynamique.typ": ex as dynamique
#import "/exercices/banque/langages/residuels-minimisation.typ": ex as residuels

#show: feuille.with(
  titre: "TD : Théorème de Kleene",
  niveau: "MPI",
  auteur: "Q. Fortier",
  exercices: (locaux, ccp, stabilite, dynamique, residuels),
  corrige: sys.inputs.at("corrige", default: "true") == "true",
)
