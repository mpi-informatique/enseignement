#import "/lib/exercice.typ": feuille
#import "/exercices/banque/langages/automates-palindromes.typ": ex as palindromes
#import "/exercices/banque/langages/automates-pile-pompage.typ": ex as pile
#import "/exercices/banque/langages/automates-monoides.typ": ex as monoides
#import "/exercices/banque/langages/automates-ordres-partiels.typ": ex as ordres
#import "/exercices/banque/langages/cloture-commutative-langage.typ": ex as commutative
#import "/exercices/banque/langages/langages-continuables-primitifs.typ": ex as primitifs
#import "/exercices/banque/langages/evaluation-acceleree-automates.typ": ex as evaluation
#import "/exercices/banque/langages/reparation-langage.typ": ex as reparation
#import "/exercices/banque/langages/morphismes-automates.typ": ex as morphismes

#show: feuille.with(
  type: "colle",
  titre: "Automates : colle ENS",
  niveau: "MPI / MP",
  exercices: (palindromes, pile, monoides, ordres, commutative,
    primitifs, evaluation, reparation, morphismes),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
