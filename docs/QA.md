# QA — conception 1.2

## Contrôles effectués sur le dossier

`python3 tools/verify_design.py` : règles P01..P07, 1862 configurations, quatre chargements, une configuration P06 et deux triplets de chemins, deux ordres de branche, preuves disponibles avant chaque étape, 21 indices. Rapport généré `design/verification_report.json`. `python3 tools/build_design_plates.py` : huit planches studio dérivées, inspection de cohérence. AUDIT et WALKTHROUGH documentent revue intégrale et simulation documentaire.

Le greybox runtime T01–T11 est désormais présent. **Greybox CI #20 réussie le 23 septembre 2026 sur `9687fe5`, Godot 4.6.2 Standard** : import headless, contrats valides/invalides, règles P01–P07, état/progression/preuves, sauvegardes, navigation, P00–P07, campagne N00–N11, sauvegarde/rechargement final, parité des contrats runtime et boot. Les erreurs JSON volontairement injectées par le test de corruption T04 apparaissent dans les logs mais le scénario de récupération est validé.

**Retour producteur : 35–40 minutes pour les énigmes de la base. Aucun rapport T12 complet ni test Android physique de l’extension n’est disponible.** La jouabilité automatisée ne valide donc ni la compréhension novice, ni le confort tactile réel, ni la durée 60–90 minutes.

## Gates de règles et progression

- P01 rejette duplicata/raccord unique erroné, accepte permutation complète ; P02 hors cadre jamais traité comme intact.
- P03 tous64 états ; P04 tous64 états, rotation4foisidentité, masquagevisuel sans altérer validation.
- P05 toutes720 permutations, quatreadmises ; gabarit des2 objets échangés ; retraitplateau depuis toutétat ; aiguille zéro iff momentnul ; double intervalle central.
- P06 eau 0..5/fragments absents ou2destinations=54 configurations ; seuleeau4/JK/KL validable. I–H noyéà4, marcheKH refusée au brancard ; deux variantes des archives admises ; segments discontinus/loops refusés ; croisement sansnœud nonconnecté.
- P07 trois pièces de même longueur, largeur/profil/attaches font ladistinction ;720 permutations ; failfeedback première violation et planning intact ; pas de temps réel.
- DeuxordresP03/P04 complets ; sortie à chaque vue ; preuves accordées sans dialoguesvus ; N05 une fois ; completed seulement après N11 ; finale exploration sans mutation.

## Sauvegarde et navigation

Interrompre avant/après chaque écrituretemp/flush/rename et chaque événement narratif. Tester hash faux, JSON tronqué, génération enveloppe différente dupayload, deux slots invalides, plus récent invalide, génération plus ancienne valide, schéma futur, stockage plein/IO refusée. Aucun reset silencieux ; message exact et récupération ; fichiers futurs conservés. Nouvelle partie confirmée backup ; refus revient campagne. Ne pas promettre zéroperte : au plus un geste comme objectif, pasun chapitre.

RetoursAndroid successifs overlay→détail→parent→pause ; dragannulé sansmutation ; pas de routesécran nonautorisées depuis sauvegarde. Veille/appbackground/force-stop pendant chargement, dialogue, feedback et finale. Aucun doublon depreuve/récompense.

## Lisibilité et accessibilité

360×640 dp et écranshauts ; chaquecommande48×48 dp minimum avec8 dp entrecibles, ycompris frise et listes alternatives P06/P05. Texte150% sansmasquage ; contrastes surassetsréels ; grayscale ; soncoupé ; mouvement réduit ; unemain et toucher/sélection partout. LireF2attaches et F3jauge sansconnaître réponse. Pas de termeculturel nécessaire. Lecteurd'écrancomplet nonannoncé sans testspécifique.

## Protocole novice obligatoire

T12 : 8 adultes novices du jeu, dont4 joueurs occasionnels de puzzles et4 joueurs familiers, téléphone portrait. Ne pas fournir solution ni coaching hors mécanisme d'indices. Consentement à observation et notes anonymes locales ; aucune télémétrie ajoutée au jeu. Chronométrer temps actif total, chaque étape, pauseshorsjeu séparées, indices utilisés, erreur de compréhension et blocagedurable. Demander aprèspartie : reconstituer en quelques phrases rôleduplancher et motif d'un détour P06, noter confort et intérêt1–5, identifier moment répétitif/frustrant. Ne pas compter temps d'entretien dans durée.

Gate T12 : aucune information introuvable ni softlock ;7/8 terminent sanscoaching externe ;6/8 expliquent les deux déductions ; médiane de confort et d'intérêt≥4/5. Pourdurée : médiane60–90 min et au moins6/8 parties entre60et90 min. Ce seuil interne est une règleproduit prudente, pas une estimation statistique du marché. Siéchec, arrêter production artistique massive et produire correctif versionné ciblant observation/déduction/ergonomie ; ni ajout de texte inutile ni temporisation. Une prochaine campagne peut être nécessaire après correction ; pas d'approbation automatique.

T18 : 8 autresnovices, assets finaux, mêmes mesures. Aucun critère levé à partir de données de joueurs connaissant déjà les réponses. Cible60–90 reste obligatoire pour annoncer satisfaction du mandat ; si non atteinte, état du projet explicitement bloqué, pas « prêt à vendre ».

## Appareils, performance et release

Deux téléphones Android physiques : un appareil4GoRAM/minimum produit et un milieudegamme ; tester au moins un ratio20:9 et un16:9/équivalentzone640 dp, puis tablette. Vérifier cibles TECHNICAL froid<5s, retourvue<400 ms, feedback<100 ms, mémoire<250 Mo ; mesurer plutôtque supposer. Campagne hors ligne dès premier lancement, aucune permission dangereuse/Internet requise.

Zérobug bloquant/majeur ouvert ; aucun placeholder/debug ; sources/licences de tousrequired_v1 ; crédits/description exacts ; captures du build livré ; signature hors Git ; AAB et politique Google revérifiée àrelease. Publier un jeu complet uniquement après passage des gates, jamais le buildinterneT12.

## Vérification 1.2

- `python3 tools/verify_expansion.py` : solutions indépendantes, 4 rangements, 2 amarres, 2 appuis ; témoins légaux pour tiroir, partage et navette ; rapports sans données utilisateur.
- `tests/rules/expansion_test.gd` : refus des états incomplets, mouvements atomiques, ancrages fixes, navette surchargée/sans pilote, volumes après vrais versements, parcours complet avec sauvegarde à chaque étape, preuve disponible avant usage, migration d'une partie 1.1 terminée et backup brut.
- `tests/ui/expansion_ui_test.gd` : instanciation effective des dix scènes, actions, sauvegarde, annulation, reset, consultation finale sans mutation.
- Tests historiques conservés, parcours complet étendu et branche inversée maintenus.
- La commande de CI doit traiter `SCRIPT ERROR` comme un échec même si Godot retourne zéro ; des erreurs historiques auraient sinon été masquées.

T12 doit noter séparément les 17 temps d'énigmes, les pauses, les indices et les tâches jugées répétitives. Ne pas confondre nombre minimal de gestes et durée humaine. Conserver les seuils de compréhension et plaisir ; aucune prétendue nouvelle durée mesurée dans ce lot.
