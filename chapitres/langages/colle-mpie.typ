#import "/enseignement.typ": feuille
#import "/chapitres/langages/exercices/automates-palindromes.typ": ex as palindromes
#import "/chapitres/langages/exercices/automates-pile-pompage.typ": ex as pile
#import "/chapitres/langages/exercices/automates-monoides.typ": ex as monoides
#import "/chapitres/langages/exercices/automates-ordres-partiels.typ": ex as ordres
#import "/chapitres/langages/exercices/cloture-commutative-langage.typ": ex as commutative
#import "/chapitres/langages/exercices/langages-continuables-primitifs.typ": ex as primitifs
#import "/chapitres/langages/exercices/evaluation-acceleree-automates.typ": ex as evaluation
#import "/chapitres/langages/exercices/reparation-langage.typ": ex as reparation
#import "/chapitres/langages/exercices/morphismes-automates.typ": ex as morphismes

#show: feuille.with(
  type: "colle",
  titre: "Automates : colle ENS",
  niveau: "MPI / MP",
  exercices: (palindromes, pile, monoides, ordres, commutative,
    primitifs, evaluation, reparation, morphismes),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
