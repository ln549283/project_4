# Plan de production — conception 1.1

État : **aucune tâche d'implémentation commencée**. Le dossier spécifie le jeu complet ; le travail intermédiaire jouable est un outil interne, jamais le livrable commercial. Ordre imposé ci-dessous. Les tâches T01–T11 utilisent des formes temporaires fidèles aux données ; les illustrations finales attendent le gate T12. Aucune décision créative n'est déléguée au prochain développeur : appliquer MASTER, PUZZLES, NARRATIVE, SCREENS_UX et ASSET_BIBLE.

| Tâche | Dépendances | Livrable exact | Critère de fin |
|---|---|---|---|
| T01 Environnement et contrats | Dossier1.1 | Godot 4.6.2 Standard, templates identiques, toolchain.lock, projet portrait1080×1920 Compatibility ; import des 3 JSON canoniques | Boot local ; identifiants/prérequis/21 aides validés ; contrat invalide refusé explicitement ; aucune clé dans Git |
| T02 Règles pures | T01 | Sept validateurs, graphe P06 distinct des ports P03 ; importer exemples/contre-exemples du rapport | Résultats identiques à verify_design.py ; quatre cargaisons et deux variantes de route admises ; aucune comparaison pixels |
| T03 État et preuves | T02 | GameState, commandes transactionnelles, DAG, evidence registry, file narrative ; valeurs initiales JSON | Deux ordres P03/P04 ; reprise/résolution idempotente ; preuves accordées sans lecture obligatoire |
| T04 Sauvegarde | T03 | Deux slots/enveloppes, hash exact, validation génération et états ; settings séparés ; nouvelle partie avec backup | Arrêt à chaque phase écriture, slot invalide, version future, disque refusé, reprise conclusion testés sans reset silencieux |
| T05 Navigation/accès | T04 | S00–S04,S12,S14, overlays, retourAndroid, carnet/épinglage/comparaison, texte150%, objectifs | Tout accessible au toucher48 dp ; retour conserve sélection et brouillon ; prochaine action visible |
| T06 Ouverture et P01/P02 | T05 | P00 ; cinq lés raccords exacts ; cinq photos temporaires avec matrice exacte ; loupe/comparer/frise | Toutes preuves avant emploi ; ordre faux explique contradiction visible ; pas de numéros solution |
| T07 P03/P04 | T06 | Six volets/3traces ; trois masques/rotation/masquer/comparer | Branches indépendantes ; 64 états chacun concordants ; masques700² conformes |
| T08 P05 | T07 | Cargaison/balance, distances fidèles, alternative six boutons, échanges atomiques et retour plateau | Quatre solutions ; tous brouillons récupérables ; aiguille informative sans calcul tapé |
| T09 P06 | T08 | Eau0–5, 2 fragments, 9 nœuds, liaisons/seuils/marches, routes par sélection, zoom + liste adjacente | Faux raccourcis expliqués ; brancard contraint ; deux trajets archives admis ; pas de chemin proposé automatiquement |
| T10 P07 | T09 | Trois candidats longueur3, inspection des faces/attaches, six cartes et coupe, simulation manuelle | Mauvais candidat réfutable ; premier conflit de frise expliqué ; pas d'action irréversible ni chrono |
| T11 Récit complet | T10 | Tous segments N00–N11, preuves et textes FR ; cartel, appel, exposition, générique ; fin inspectable | Campagne du début à fin, interruption à chaque segment, objectif visible à chaque jonction ; completed seulement après fin |
| T12 Gate novice | T11 | Sessions observées du parcours intégral avec 8 nouveaux joueurs, protocole QA et rapport anonymisé local | Compréhension et absence de blocage ; durée mesurée. Si durée/qualité échoue, STOP production artistique massive, corrections ciblées et dossier versionné avant poursuite |
| T13 Masters héros | T12 accepté | Atelier/maquette, panorama, 5 photos, plancher/assemblage, fond de l'établi, titre/icône selon bible | Géométrie et continuité passées ; revue sur téléphone360 dp ; sources/calques/pivots livrés |
| T14 Dérivés et UI | T13 | Tous required_v1 visuels restants du CSV ; dérivés reproductibles ; polices/licences | Manifest sans manque ni doublon ; cibles/zoom/contraste/150% ; aucune texture portant texte fonctionnel |
| T15 Audio/animation | T14 | Deux musiques, troisambiances, SFX requis, animations contractuelles et mouvement réduit | Pas d'information exclusivement sonore ; reprise/pause sans empilement ; mix casque/haut-parleur |
| T16 Intégration finale | T15 | Remplacer placeholders sans changer règles ; tous labels et assets FR ; crédits exacts | Aucun placeholder/debug/IDauteur visible ; campagne toujours valide avec artfinal |
| T17 QA Android | T16 | APK testé sur téléphones physiques bas/milieu gamme et formats tablette ; protocole QA | Sauvegarde/veille/reprise, mémoire/perfs, lisibilité, parcoursfinal et preuves photographiques validés |
| T18 Validation commerciale | T17 | Secondes parties novices avec assets finaux ; donnéesdurée/confort ; corrections terminées | Pas de bug bloquant ; critères QA ; promesse60–90 justifiée, sinon blocage explicite de commercialisation |
| T19 Livraison | T18 | AAB signé, licences/crédits, captures réelles, descriptionFR, déclarations store, archive source/reproductibilité | Politique Google actuelle vérifiée, test d'installation hors ligne, signature conservée horsrepo ; pas de publication sans autorisation explicite correspondante |

## Definition of done de chaque tâche

Mettre à jour docs/PRODUCTION (journal), MASTER (état exact/prochaine tâche), vérifications avec résultats et limites. Exécuter les contrôles pertinents, pas une batterie répétitive sans risque identifié. Aucun « terminé » fondé uniquement sur compilation. Enregistrer sources/licences des assets au fil de l'eau. Tout changement de règle exige JSON+prose+planches+tests synchronisés.

## Périmètre obligatoire / exclusion

La colonne scope du manifeste fait foi pour la fabrication : required_v1 obligatoire, ignore_v1 ne pas fabriquer. MASTER énumère les systèmes exclus. Aucun plugin de replay, traduction, export diagnostic ou analytics anticipé. En cas de dérive coût, réduire le décor et les mouvements facultatifs ; ne jamais retirer preuves, indices, fin, sauvegarde ou accessibilité.

## Première tâche à exécuter

**T01 uniquement comme premier lot :** relever HEAD, lire TECHNICAL, installer la version explicite depuis la source officielle, inscrire versions/checksums disponibles dans toolchain.lock, créer le projet et les imports contrôlés ; fournir commande de boot et résultat du test de contrat. Puis poursuivre T02. Ne pas partir d'une scène P03 isolée en oubliant le reste du parcours.
