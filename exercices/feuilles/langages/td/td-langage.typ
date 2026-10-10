#import "/lib/exercice.typ": feuille
#import "/exercices/banque/langages/mots-qui-commutent.typ": ex as commutation
#import "/exercices/banque/langages/mots-de-fibonacci.typ": ex as fibonacci
#import "/exercices/banque/langages/regles-expressions-regulieres.typ": ex as regles
#import "/exercices/banque/langages/exemples-langages-reguliers.typ": ex as exemples
#import "/exercices/banque/langages/distance-de-hamming.typ": ex as hamming
#import "/exercices/banque/langages/cloture-sur-mots.typ": ex as sur-mots

#show: feuille.with(
  titre: "TD : Langages réguliers",
  niveau: "MPI",
  auteur: "Q. Fortier",
  exercices: (commutation, fibonacci, regles, exemples, hamming, sur-mots),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
