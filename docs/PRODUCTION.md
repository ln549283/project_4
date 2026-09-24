# Journal de production

Plan canonique : [../PRODUCTION_PLAN.md](../PRODUCTION_PLAN.md). Ne pas maintenir un second découpage ici.

- 22 septembre 2026 : conception 1.0, données et planches techniques ; pas de jeu.
- 23 septembre 2026 : audit critique 1.1 ; P06 remplacé, preuves rendues explicites, récit corrigé, scope réduit, manifest/bible et plan de production synchronisés.
- 23 septembre 2026 — **T01** : Godot 4.6.2 Standard et checksums verrouillés dans `toolchain.lock` ; projet portrait Compatibility créé ; contrats canoniques chargés et validés au boot ; contrat invalide refusé par test.
- 23 septembre 2026 — **T02–T04** : validateurs purs P01–P07, progression/état/preuves et sauvegarde à deux générations implémentés. Corrections de production apportées aux routes P03 et à la validation numérique P06 des snapshots. Tests de règles, deux ordres P03/P04, idempotence, corruption, interruptions d'écriture, version future, refus d'IO et reprise de conclusion passés.
- 23 septembre 2026 — **T05–T10** : navigation/accès et greybox P00–P07 implémentés avec placeholders fonctionnels. Les tests couvrent cibles tactiles minimales, P00/P01/P02, branches P03/P04, quatre solutions P05, deux variantes de route P06 et P07.
- 23 septembre 2026 — **T11** : contenus FR N00–N11, preuves, conclusion et exploration reliés ; test de campagne P00→P07→N11 avec sauvegarde/rechargement ajouté. Parité `design/puzzles.json`↔`content/puzzles.json` et `design/hints_fr.json`↔`content/hints_fr.json` contrôlée.
- 23 septembre 2026 — vérification consolidée : **GitHub Actions Greybox CI #20 réussie sur `9687fe5` sous Godot 4.6.2**. T01 à T11, import, tests GDScript, campagne complète, parité de contenu et boot headless sont verts.
- 23 septembre 2026 — **distribution T12 Web** : preset Godot Web ajouté en mono-thread, templates 4.6.2 vérifiés par SHA-256, export automatique `build/web/index.html`, contrôle de l’artifact Pages et simulation d’hébergement sous `/project_4/`. Le workflow **Deploy Web Greybox #1** a construit et déployé avec succès `ca780ee` sur `https://ln549283.github.io/project_4/`. **Greybox CI #22** est également verte sur ce commit. Cette URL est un moyen de distribution du greybox, pas une validation du gate T12.

- Extension 1.2 demandée après retour de durée 35–40 minutes : dix puzzles P08–P17, 30 indices, scènes visuelles, progression et narration intégrées, migration 1.1 sans perte de résolutions. Deux erreurs bloquantes préexistantes corrigées dans les boards P05/P07. Les résultats reproductibles figurent dans les rapports de vérification.

**État : greybox étendu implémenté ; prochaine tâche T12 sur 17 énigmes.** Les mesures humaines de l'extension et les tests Android physiques restent à faire. Aucun asset final ni validation commerciale annoncé. La base de durée 35–40 minutes est un retour producteur, pas un rapport T12 à huit participants.
