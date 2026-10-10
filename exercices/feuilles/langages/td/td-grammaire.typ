#import "/lib/exercice.typ": feuille
#import "/exercices/banque/langages/miroir-langage-hors-contexte.typ": ex as miroir
#import "/exercices/banque/langages/construire-grammaires.typ": ex as construire
#import "/exercices/banque/langages/langages-engendres-grammaires.typ": ex as langages
#import "/exercices/banque/langages/pompage-intersection-complementaire.typ": ex as pompage
#import "/exercices/banque/langages/ambiguite-grammaire-reguliere.typ": ex as ambiguite
#import "/exercices/banque/langages/forme-normale-chomsky.typ": ex as chomsky
#import "/exercices/banque/langages/dyck-grammaires-denombrement.typ": ex as dyck

#let sujet = (
  titre: "TD : Grammaires",
  exercices: (miroir, construire, langages, pompage, ambiguite, chomsky, dyck),
  bareme: none,
)

#show: feuille.with(
  type: "td",
  titre: sujet.titre,
  niveau: "MPI",
  auteur: "Q. Fortier",
  exercices: sujet.exercices,
  bareme: sujet.bareme,
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
