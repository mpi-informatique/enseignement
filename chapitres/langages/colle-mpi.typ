#import "/enseignement.typ": feuille
#import "/chapitres/langages/exercices/lemme-arden.typ": ex as arden
#import "/chapitres/langages/exercices/palindromes-et-rationalite.typ": ex as palindromes
#import "/chapitres/langages/exercices/ensembles-inevitables.typ": ex as inevitables
#import "/chapitres/langages/exercices/mots-de-dyck.typ": ex as dyck

#show: feuille.with(
  type: "colle",
  titre: "Colle : langages et automates",
  niveau: "MPI",
  auteur: "Q. Fortier",
  exercices: (arden, palindromes, inevitables),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
