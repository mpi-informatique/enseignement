#!/usr/bin/env python3
"""Tester les régions OCaml d'une copie avec les mêmes oracles que le corrigé."""

import argparse
from pathlib import Path
import re
import subprocess
from tempfile import TemporaryDirectory


TESTS = {
    "1.5": (("1.5",), "let a2 = {1.5}", "test_a2 a2"),
    "1.6": (("1.6",), "{1.6}", "test_numero numero"),
    "1.7": (("1.7",), "{1.7}", "test_etats_accessibles etats_accessibles"),
    "1.8": (("1.7", "1.8"), "{1.7}\n{1.8}", "test_partie_accessible partie_accessible"),
    "1.17": (("1.17",), "{1.17}", "test_existe_morphisme existe_morphisme"),
    "1.19": (("1.7", "1.19"), "{1.7}\n{1.19}", "test_produit etats_accessibles produit"),
    "1.27": (("1.27",), "{1.27}", "test_renomme renomme"),
}
ATTENTES = re.compile(r"\(\* TEST (\d+\.\d+): (success|failure)(?:: ([^*]+))? \*\)")


def extraire(source, nom):
    debut = f"(* BEGIN {nom} *)\n"
    fin = f"(* END {nom} *)"
    morceaux = source.split(debut)
    assert len(morceaux) == 2, f"Région {nom} absente ou dupliquée"
    region = morceaux[1].split(fin)
    assert len(region) == 2, f"Fin de région {nom} absente ou dupliquée"
    return region[0].strip()


def executer(ocamlc, programme, nom):
    with TemporaryDirectory(prefix="copie-mines-ponts-") as dossier:
        source = Path(dossier) / f"{nom}.ml"
        executable = Path(dossier) / nom
        source.write_text(programme + "\n", encoding="utf-8")
        compilation = subprocess.run(
            [ocamlc, "-o", str(executable), str(source)], text=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        if compilation.returncode != 0:
            return False, compilation.stderr
        try:
            execution = subprocess.run([str(executable)], text=True,
                                       stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                       timeout=5)
        except subprocess.TimeoutExpired:
            return False, "Délai de 5 secondes dépassé : le programme ne termine pas."
        return execution.returncode == 0, execution.stderr


def tester_copie(ocamlc, fichier, tests):
    texte = fichier.read_text(encoding="utf-8")
    attentes = {nom: (resultat, diagnostic.strip())
                for nom, resultat, diagnostic in ATTENTES.findall(texte)}
    regions = {nom: extraire(texte, nom) for nom in attentes}
    inconnues = attentes.keys() - TESTS.keys()
    assert not inconnues, f"Tests inconnus dans {fichier} : {', '.join(sorted(inconnues))}"
    assert attentes, f"Aucun test déclaré dans {fichier}"
    reference = Path(__file__).with_name("corrige.ml").read_text(encoding="utf-8")
    for nom, (attendu, diagnostic) in attentes.items():
        assert attendu == "success" or diagnostic, f"Diagnostic absent pour {fichier}, question {nom}"
        dependances, patron, appel = TESTS[nom]
        programme = patron
        for dependance in dependances:
            if dependance in regions:
                code = regions[dependance]
            else:
                assert dependance == "1.7", f"Région {dependance} absente pour tester {nom}"
                code = extraire(reference, "etats_accessibles")
                print(f"{fichier.name}, question {nom} : parcours du corrigé utilisé pour le test, question 7 absente.")
            programme = programme.replace("{" + dependance + "}", code)
        programme += "\n" + tests + f"\nlet () = {appel}\n"
        succes, erreur = executer(ocamlc, programme, nom.replace(".", "-"))
        if attendu == "success":
            assert succes, f"{fichier}, question {nom} devait réussir : {erreur}"
        else:
            assert not succes, f"{fichier}, question {nom} devait échouer"
    print(f"{fichier.name} : {len(attentes)} groupes de tests vérifiés.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ocamlc", default="ocamlc")
    parser.add_argument("copies", nargs="+", type=Path)
    args = parser.parse_args()
    tests = Path(__file__).with_name("tests.ml").read_text(encoding="utf-8")
    for copie in args.copies:
        tester_copie(args.ocamlc, copie, tests)


if __name__ == "__main__":
    main()
