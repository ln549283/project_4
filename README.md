# Les Rives pliées

Jeu d'énigmes narratif tactile premium pour Android, conçu pour Nibylo Games.

**Dépliez une ville. Retrouvez le chemin de ceux qu'elle a sauvés.**

Une restauratrice remet en état une maquette de ville en papier. Reconstituer ses images, ses trajets et ses mécanismes lui permettra de comprendre pourquoi sa mère a démonté son propre atelier pendant une crue.

## Reprendre le projet

1. Lire [MASTER_PLAN.md](MASTER_PLAN.md), source de vérité.
2. Lire [docs/PRODUCTION.md](docs/PRODUCTION.md), état et prochain travail précis.
3. Exécuter `python3 tools/verify_design.py`.
4. Commencer le lot PROD-01, sans nouvelle sélection de concept.

**État : conception v1.0 terminée ; production du jeu non commencée.** Les scripts sont des vérificateurs de conception, pas le jeu. La durée cible de 60–90 min doit être confirmée par playtests.

Le dossier inclut histoire complète, sept énigmes, données et solutions vérifiées, aides, UX, inventaire d'assets, DA/son, architecture Godot/Android, sauvegarde et protocole QA. Les gabarits SVG de `design/plates/` sont destinés à la construction des mécanismes.

## Vérifier

Python 3 standard, sans dépendance :

```sh
python3 tools/verify_design.py
python3 tools/build_design_plates.py
```

Résultats : `design/verification_report.json` et `design/plates/`.

Le contenu original du projet n'est pas placé sous licence open source par le seul fait de la visibilité publique du dépôt. Les bibliothèques, fontes et assets tiers utilisés ultérieurement doivent conserver leurs propres licences dans le registre de production.
