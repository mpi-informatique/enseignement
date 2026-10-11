#import "/lib/exercice.typ": exercice, question, partie, feuille

#let ex = exercice(
  sujet-ecrit: true, // Mettre false pour un exercice oral ou un extrait autonome.
  meta: (
    titre: "Titre du sujet de concours",
    chapitres: ("langages-reguliers", "automates-finis"),
    difficulte: 2, niveaux: ("MPI",), duree: (4, 0),
      // concours: (nom: "ENS", annee: 2019, filiere: "MP", oral: false),
  ),
  // Corrections conservées dans les données, sans affichage. Remarques du jury en italique.
  corrections: none, // Exemple : [- Question 1 : ajouter l'hypothèse de finitude.]
  remarques: none,
  contenu: (
    [Les réponses doivent être justifiées.
      On fixe un alphabet $Σ$.],
    partie("I", "Langages", commentaire: none, contenu: (
      partie("I.A", "Langages finis", contexte: ([On fixe un alphabet $Σ$.],), contenu: (
        question([Montrer qu'un langage fini sur $Σ$ est régulier.],
          commentaire: none, // Observation du jury, affichée en italique avant la solution.
          solution: [Un mot est décrit par la concaténation de ses lettres
            (par $ε$ pour le mot vide).
            Une union finie de telles expressions décrit tout langage fini ; $∅$ décrit le langage vide.]),
      )),
      partie("I.B", "Miroir", contexte: ([On fixe un alphabet $Σ$.],), contenu: (
        question([Le miroir d'un langage fini est-il régulier ?],
          solution: [Il est fini, donc régulier.]),
      )),
    )),
  ),
)

#show: feuille.with(
  type: "devoir", // Un concours est un devoir avec une attribution.
  titre: ex.meta.titre,
  niveau: ex.meta.niveaux.join(" / "),
  concours: ex.meta.concours,
  exercices: (ex,),
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
