# Journal de production

Plan canonique : [../PRODUCTION_PLAN.md](../PRODUCTION_PLAN.md). Ne pas maintenir un second découpage ici.

- 22 septembre 2026 : conception 1.0, données et planches techniques ; pas de jeu.
- 23 septembre 2026 : audit critique 1.1 ; P06 remplacé, preuves rendues explicites, récit corrigé, scope réduit, manifest/bible et plan de production synchronisés.
- 23 septembre 2026 — **T01** : Godot 4.6.2 Standard et checksums verrouillés dans `toolchain.lock` ; projet portrait Compatibility créé ; contrats canoniques chargés et validés au boot ; contrat invalide refusé par test.
- 23 septembre 2026 — **T02–T04** : validateurs purs P01–P07, progression/état/preuves et sauvegarde à deux générations implémentés. Corrections de production apportées aux routes P03 et à la validation numérique P06 des snapshots. Tests de règles, deux ordres P03/P04, idempotence, corruption, interruptions d'écriture, version future, refus d'IO et reprise de conclusion passés.
- 23 septembre 2026 — **T05–T10** : navigation/accès et greybox P00–P07 implémentés avec placeholders fonctionnels. Les tests couvrent cibles tactiles minimales, P00/P01/P02, branches P03/P04, quatre solutions P05, deux variantes de route P06 et P07.
- 23 septembre 2026 — **T11** : contenus FR N00–N11, preuves, conclusion et exploration reliés ; test de campagne P00→P07→N11 avec sauvegarde/rechargement ajouté. Parité `design/puzzles.json`↔`content/puzzles.json` et `design/hints_fr.json`↔`content/hints_fr.json` contrôlée.
- 23 septembre 2026 — vérification consolidée : **GitHub Actions Greybox CI #20 réussie sur `9687fe5` sous Godot 4.6.2**. T01 à T11, import, tests GDScript, campagne complète, parité de contenu et boot headless sont verts.

**État : T01–T11 terminés et vérifiés automatiquement. T12 est la prochaine tâche et le prochain gate.** Le protocole à 8 novices est déjà défini dans [QA.md](QA.md). Aucune session novice réelle ni mesure de durée n'a encore été réalisée ; la cible 60–90 minutes reste donc non validée.

**Blocage volontaire de production : ne pas démarrer T13.** Aucun asset final, APK/AAB final ou validation commerciale n'est annoncé. La prochaine action nécessite l'observation de 8 nouveaux joueurs sur le greybox conformément à T12 ; si le gate échoue, stopper la production artistique massive et appliquer seulement les corrections ciblées prévues.
