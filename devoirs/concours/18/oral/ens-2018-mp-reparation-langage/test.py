"""Comparer les récurrences des questions 7–9 à deux recherches indépendantes.

Les cas couvrent l'automate non déterministe, les langages vides, le mot vide,
les boucles, les insertions et une suppression qui ne commence pas en position 0.
Ces fonctions vérifient les formules mathématiques ; aucun code Python n'est
publié dans le sujet ou son corrigé.
"""
from collections import deque
from heapq import heapify, heappop, heappush
from math import inf


def accepte(n, initiaux, finaux, arcs, mot):
    etats = set(initiaux)
    for lettre in mot:
        etats = {q for p, a, q in arcs if p in etats and a == lettre}
    return bool(etats & finaux)


def suppression(n, initiaux, finaux, arcs, mot):
    atteints = set(initiaux)
    d = [0 if q in initiaux else inf for q in range(n)]
    r = d.copy()
    for a in mot:
        atteints = {q for p, b, q in arcs if p in atteints and a == b}
        d = [min(d[q] + 1, 0 if q in atteints else inf) for q in range(n)]
        suivant = d.copy()
        for p, b, q in arcs:
            if a == b:
                suivant[q] = min(suivant[q], r[p])
        r = suivant
    return min((r[q] for q in finaux), default=inf)


def distances(n, arcs):
    adj = [[] for _ in range(n)]
    for p, _, q in arcs:
        adj[p].append(q)
    resultat = []
    for depart in range(n):
        d = [inf] * n
        d[depart] = 0
        file = deque([depart])
        while file:
            p = file.popleft()
            for q in adj[p]:
                if d[q] == inf:
                    d[q] = d[p] + 1
                    file.append(q)
        resultat.append(d)
    return resultat


def reparation(n, initiaux, finaux, arcs, mot, supprimer):
    d = distances(n, arcs)
    cout = [min((d[i][q] for i in initiaux), default=inf) for q in range(n)]
    for a in mot:
        suivant = [c + 1 if supprimer else inf for c in cout]
        for p, b, r in arcs:
            if a == b:
                for q in range(n):
                    suivant[q] = min(suivant[q], cout[p] + d[r][q])
        cout = suivant
    return min((cout[q] for q in finaux), default=inf)


def oracle(n, initiaux, finaux, arcs, mot, supprimer):
    """Plus court chemin sur (position dans le mot, état de l'automate)."""
    adj = [[] for _ in range(n)]
    for p, a, q in arcs:
        adj[p].append((a, q))
    meilleurs = {(0, q): 0 for q in initiaux}
    file = [(0, 0, q) for q in initiaux]
    heapify(file)
    while file:
        c, i, p = heappop(file)
        if c != meilleurs[i, p]:
            continue
        if i == len(mot) and p in finaux:
            return c
        voisins = [(i, q, 1) for _, q in adj[p]]
        if i < len(mot):
            voisins += [(i + 1, q, 0) for a, q in adj[p] if a == mot[i]]
            if supprimer:
                voisins.append((i + 1, p, 1))
        for j, q, poids in voisins:
            if c + poids < meilleurs.get((j, q), inf):
                meilleurs[j, q] = c + poids
                heappush(file, (c + poids, j, q))
    return inf


ab_etoile = (2, {0}, {0}, [(0, 'a', 1), (1, 'b', 0)])
non_deterministe = (4, {0, 1}, {3}, [
    (0, 'a', 0), (0, 'a', 2), (1, 'b', 2), (2, 'b', 3), (3, 'a', 3)])
cas = [
    (*ab_etoile, ''), (*ab_etoile, 'aab'), (*ab_etoile, 'aa'),
    (*ab_etoile, 'abba'), (*ab_etoile, 'abab'),
    (*non_deterministe, ''), (*non_deterministe, 'baab'),
    (*non_deterministe, 'bbba'),
    (2, {0}, set(), [(0, 'a', 1)], 'a'),
    (1, {0}, {0}, [], 'aba'),
]
for n, initiaux, finaux, arcs, mot in cas:
    donnees = (n, initiaux, finaux, arcs, mot)
    attendu = min((j - i for i in range(len(mot) + 1)
                   for j in range(i, len(mot) + 1)
                   if accepte(n, initiaux, finaux, arcs, mot[:i] + mot[j:])),
                  default=inf)
    assert suppression(*donnees) == attendu, donnees
    for supprimer in (False, True):
        assert reparation(*donnees, supprimer) == oracle(*donnees, supprimer), donnees
print('Réparation de langages : 10 cas, suppression et deux variantes d\'édition vérifiés.')
