#import "/load.typ": feuille
#import "/chapitres/langages/exercices/palindromes-et-rationalite.typ": ex as palindromes
#import "/chapitres/langages/exercices/ensembles-inevitables.typ": ex as inevitables
#import "/chapitres/langages/exercices/mots-de-dyck.typ": ex as dyck

#show: feuille.with(
  type: "colle",
  titre: "Colle : langages et automates",
  niveau: "MPI",
  auteur: "Q. Fortier",
  exercices: (palindromes, inevitables),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
