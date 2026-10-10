#import "/lib/exercice.typ": feuille
#import "/exercices/banque/langages/lemme-arden.typ": ex as arden
#import "/exercices/banque/langages/palindromes-et-rationalite.typ": ex as palindromes
#import "/exercices/banque/langages/ensembles-inevitables.typ": ex as inevitables
#import "/exercices/banque/langages/mots-de-dyck.typ": ex as dyck

#show: feuille.with(
  type: "colle",
  titre: "Colle : langages et automates",
  niveau: "MPI",
  auteur: "Q. Fortier",
  exercices: (arden, palindromes, inevitables),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
