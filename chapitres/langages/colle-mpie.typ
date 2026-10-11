#import "/load.typ": feuille
#import "/devoirs/concours/oral/ens/ens-oral-mp-automates-palindromes.typ": ex as palindromes
#import "/devoirs/concours/oral/ens/ens-oral-mp-automates-pile-pompage.typ": ex as pile
#import "/devoirs/concours/oral/ens/ens-oral-mp-automates-monoides.typ": ex as monoides
#import "/devoirs/concours/oral/ens/ens-oral-mp-automates-ordres-partiels.typ": ex as ordres
#import "/devoirs/concours/oral/ens/ens-oral-mp-cloture-commutative-langage.typ": ex as commutative
#import "/devoirs/concours/oral/ens/ens-oral-mp-langages-continuables-primitifs.typ": ex as primitifs
#import "/devoirs/concours/oral/ens/ens-oral-mp-evaluation-acceleree-automates.typ": ex as evaluation
#import "/devoirs/concours/oral/ens/ens-oral-mp-reparation-langage/ens-oral-mp-reparation-langage.typ": ex as reparation
#import "/chapitres/langages/exercices/morphismes-automates.typ": ex as morphismes

#show: feuille.with(
  type: "colle",
  titre: "Automates : colle ENS",
  niveau: "MPI / MP",
  exercices: (palindromes, pile, monoides, ordres, commutative,
    primitifs, evaluation, reparation, morphismes),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
