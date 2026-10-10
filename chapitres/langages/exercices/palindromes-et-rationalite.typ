#import "/lib/exercice.typ": exercice
#import "/devoirs/concours/22/centrale-2022-mp-informatique/centrale-2022-mp-informatique.typ": palindromes

// La partie est partagée avec le sujet ; seuls ses rappels sont ajoutés ici.
#let ex = exercice(
  meta: (..palindromes.meta, titre: palindromes.titre, niveaux: ("MPI", "MP")),
  contenu: palindromes.contexte + palindromes.contenu,
)
