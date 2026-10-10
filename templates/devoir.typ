#import "/lib/exercice.typ": feuille
#import "/templates/exercice.typ": ex

#show: feuille.with(
  type: "devoir",
  titre: "Devoir",
  niveau: "MPI",
  auteur: none,
  exercices: (ex,),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
  nouvelle-page: false,
)
