#import "/enseignement.typ": feuille
#import "/chapitres/langages/exercices/mots-qui-commutent.typ": ex as commutation
#import "/chapitres/langages/exercices/mots-de-fibonacci.typ": ex as fibonacci
#import "/chapitres/langages/exercices/regles-expressions-regulieres.typ": ex as regles
#import "/chapitres/langages/exercices/exemples-langages-reguliers.typ": ex as exemples
#import "/chapitres/langages/exercices/distance-de-hamming.typ": ex as hamming
#import "/chapitres/langages/exercices/cloture-sur-mots.typ": ex as sur-mots

#show: feuille.with(
  titre: "TD : Langages réguliers",
  niveau: "MPI",
  auteur: "Q. Fortier",
  exercices: (commutation, fibonacci, regles, exemples, hamming, sur-mots),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
