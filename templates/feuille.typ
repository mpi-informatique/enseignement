#import "/lib/exercice.typ": feuille
#import "/templates/exercice.typ": ex

#show: feuille.with(
  type: "td",
  titre: "Travaux dirigés",
  niveau: "MPI",
  exercices: (ex,), // Importer d'autres exercices sous des alias et les ajouter ici.
  corrige: sys.inputs.at("corrige", default: "false") == "true",
  nouvelle-page: false,
)
