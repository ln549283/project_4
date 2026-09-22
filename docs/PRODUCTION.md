# Production et mémoire intersessions

## État au 22 septembre 2026

Conception v1.0 livrée, règles formelles vérifiées, zéro code de jeu runtime. Les gabarits de puzzle sont des plans techniques ; aucun écran final illustré ni morceau sonore n'a encore été produit. Le commit de cette session est le point de départ de production, pas une version jouable.

**Prochaine tâche : PROD-01**, précisément décrite ci-dessous. Ne pas explorer de nouveaux concepts, ne pas rebaptiser, ne pas réécrire l'histoire. Le producteur a délégué les décisions de réalisation ; résoudre les détails d'implémentation selon ce contrat et consigner toute correction nécessaire.

## Lots ordonnés et critères de sortie

| Lot | Travail concret | Sortie vérifiable | Dépendance |
|---|---|---|---|
| PROD-01 Fondations | Installer/figer Godot 4.6.2 et templates, créer projet portrait Compatibility ; GameState, Progression, SaveService ; contrôleur générique de volets et P03 | P03 se manipule et valide les 64 états comme l'oracle ; fermeture/reprise des bits ; tests d'écriture interrompue ; build debug local | Conception |
| PROD-02 Tous les mécanismes | Implémenter validateurs P01/P02/P04/P05/P06/P07 et scènes fonctionnelles ; indices/carnet/annulation/retour ; P00 | Partie complète du début à la fin en art de construction, aucune nouvelle règle inventée ; tous états oracle comparés | PROD-01 |
| PROD-03 Identité et assets maîtres | Fonds des 3 lieux, maquette, 8 bâtiments, personnages, typographie, iconographie ; gabarits fonctionnels habillés | Référence visuelle cohérente sur établi + P03 + P05, captures Android ; assets fonctionnels fidèles | PROD-01, peut avancer après fondations |
| PROD-04 Histoire et contenu final | 5 photos cohérentes, panorama, calques, règles, script complet, finale et épilogue, progression dans les deux ordres | Aucun placeholder ; tous textes exacts ; continuité des preuves vérifiée | PROD-02 et PROD-03 |
| PROD-05 Son et animation | Musiques/ambiances/SFX, transitions, six tableaux finaux ; mouvement réduit ; polissage matériel | Mix téléphone/casque, commandes accessibles, aucun effet masquant une information | PROD-04 |
| PROD-06 QA et corrections | Vérifications Android, sauvegardes, accessibilité, performances, playtests aveugles, correction des problèmes concrets | Matrice QA remplie, durée mesurée, bugs majeurs fermés | PROD-05 |
| PROD-07 Release | Vérifier politique Google du moment, titre/identité, licences, fiche store, captures, AAB signé et test installation | Dossier de publication complet, build et compte vérifiés selon accès disponibles | PROD-06 |

Les lots sont des étapes internes vers le jeu entier. Ne pas s'arrêter après un prototype ni présenter PROD-01/02 comme produit commercial. Les sessions disponibles et leurs quotas ne garantissent pas un nombre fixe d'heures de travail ; prioriser continuité et artefacts persistés.

## PROD-01 : premier travail exécutable de la prochaine session

1. Lire master, vérifier le HEAD et instructions du dépôt ; lancer `python3 tools/verify_design.py`.
2. Contrôler présence de Godot et runtime Android. Installer depuis sources officielles si autorisé et disponible ; enregistrer version, templates et méthode reproductible. Ne pas changer de moteur par commodité sans documenter un blocage réel.
3. Créer `project.godot` : base 1080×1920 portrait, renderer Compatibility, mise à l'échelle conservant proportions, safe-area UI calculée.
4. Importer les données de design, coder `RoutesRules.trace()` sans dépendance au rendu ; comparer exhaustivement P03 à l'oracle et garder cette vérification en CI.
5. Créer six `PaperFlap` réutilisables, les ports et trois tracés. Géométrie de contrôle dans `design/plates/p03_solution.svg`, sans exposer le mot solution au joueur.
6. Implémenter état et sauvegarde à deux slots selon TECHNICAL. Tester retour écran et suppression du processus ; relever ce qui n'a pas pu être testé faute d'appareil.
7. Commit/push de l'incrément cohérent. Mettre à jour ce journal et passer à PROD-02 ; ne pas demander au producteur une validation du prototype.

## Règles de dépôt et reprise

- `main` est la branche de référence choisie pour ce dépôt initialement vide. Conserver une seule ligne de production ; si une protection impose une branche, créer une branche nommée `production/folded-shores` et une PR, sans dupliquer deux variantes du jeu.
- Commits de taille logique : données+contrat ensemble ; assets avec sources/provenance ; correctif avec vérification ciblée.
- Aucun secret, keystore, mot de passe ou contenu privé utilisateur. `.godot/`, builds, fichiers temporaires et caches exclus.
- Chaque fin de session modifie cette page : état exact, livrables, tests exécutés, erreurs ouvertes, prochaine action. Mettre aussi le résumé de l'état en tête de MASTER_PLAN.
- Si une hypothèse est invalidée, noter « observation → modification → justification → test », augmenter version design si règles changées. Ne jamais effacer l'historique de décision.
- Une prochaine session ne doit pas avoir besoin de la conversation. Aucun lien de discussion n'est une dépendance de production.

## Journal

### Session CONCEPTION — 22 septembre 2026

- Dépôt `ln549283/project_4` trouvé vide ; branche par défaut `main`, aucun code ou AGENTS préexistant à préserver.
- Quatre pistes comparées ; sélection du livre-maquette fluvial, titre Les Rives pliées, achat unique 3,49 €.
- Récit complet rédigé : Nelle, Aline, Jo, crue, reconstruction des preuves, geste du plancher, appel et exposition.
- Sept énigmes et P00 définies avec données, règles, solutions, feedback, trois aides et revue novice.
- P03/P06 corrigées après exploration de topologie pour éviter des solutions involontaires et des cases inutiles.
- P05 reconnaît quatre solutions légitimes ; vérification exhaustive, pas de solution graphique arbitrairement privilégiée.
- Inventaire assets, DA/son, écrans, sauvegarde et architecture Godot établis. Gabarits mécaniques SVG générés.
- Vérifications combinatoires : 21 760 configurations, résultats dans `design/verification_report.json` ; deux parcours narratifs complets.
- QA humaine/Android/visuelle finale non faite car production non commencée. Durée commerciale non encore mesurée.
- **Prochain lot : PROD-01.** Aucun blocage de conception nécessitant un choix du producteur.

## État des livrables

| Livrable | État |
|---|---|
| Vision, structure, règles | Terminé v1.0 |
| Scénario complet et textes FR | Terminé v1.0 |
| Puzzles / solutions / aides | Terminé et vérifié formellement |
| UX / architecture / sauvegarde | Spécifiées, non implémentées |
| Inventaire art/son | Spécifié, production à faire |
| Gabarits géométriques | Livrés pour construction, non assets finaux |
| Jeu jouable | Non commencé |
| Playtests et durée | À mesurer en PROD-06 |
| Android/store | À produire puis vérifier |
