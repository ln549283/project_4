> **Version active : 1.2.** Les paragraphes 1.1 ci-dessous décrivent la base conservée ; l’extension en fin de document et [EXPANSION_1_2.md](EXPANSION_1_2.md) définissent les ajouts et prennent priorité sur les anciens nombres et prérequis.

# Audit critique externe — 23 septembre 2026

## Avis du Game Director

La conception 1.0 ne justifiait pas une production artistique complète : seconde énigme de connexions très proche de la première, fausse profondeur de contraintes, sélection finale trop évidente, durée optimiste et contrats techniques/visuels contradictoires. **1.1 peut entrer en construction contrôlée**, avec gate de parcours complet avant fabrication massive. La commercialisation n'est pas validée : durée, plaisir tactile, lisibilité des preuves et qualité finale restent à mesurer. Aucun argument « plusieurs mois de studio » ne remplace ces résultats.

Périmètre lu : totalité des25 fichiers initiaux (master/README,8 annexes, JSONpuzzles/indices/rapport, CSVassets,2 scripts,8 SVG et gitignore). Audit documentaire, inspection des planches et vérification des données ; aucun exécutable de jeu n'existait. Les corrections sont directement appliquées, pas seulement proposées ci-dessous.

## Faiblesses et corrections

| ID / sévérité | Défaut initial et conséquence | Correction appliquée | Vérification / limite |
|---|---|---|---|
| A01 Majeur | Rapport accusant Aline dans master, dossier neutre ailleurs | Récit de reconstruction, pas d'accusation/fausse exonération | MASTER/NARRATIVE alignés |
| A02 Majeur | Mère vivante et témoignage opportunément caché jusqu'à fin | Témoignage fourni après P01, participation volontaire ; but matériel explicite | evidence.json garantit disponibilité |
| A03 Majeur | Atelier détruit mais lieuprésent ancien atelier | Salle municipale distincte ; atelier historique non reconstruit | Narration et DA corrigées |
| A04 Moyen | Six moments annoncés pour cinq photos | Cinqphotos, six phases de reconstitution sans correspondance1:1 | Matrice et script relus |
| A05 Majeur | P06 neufvolets répète P03 sixvolets | P06 remplacé par eau/fragments/mobilité partagée |54 configurations,1cartevalide,2triplets de routes |
| A06 Moyen | P01/P04 survendus commeénigmes longues | Apprentissage2–4 min et respiration1–3 min assumés | Difficulté empirique à mesurer |
| A07 Majeur | Règle nonvoisinage médicaments/teintures n'élimine aucune solution | Supprimée texte/données/validateur/UI | Quatre mêmes solutions obtenues par seules contraintes utiles |
| A08 Majeur | Échanges de charges peuvent déplacer grandecharge sousarceau | Transaction vérifiant deux objets, rejet intégral, retour plateau permanent | Cas de test obligatoire T08 |
| A09 Majeur | Sixslots équidistants dessinés pour bras −3..−1,+1..+3 | Double intervalle central et commandes48 dp séparées de la géométrie | Planche P05 et bible corrigées |
| A10 Majeur | P07 choisir longueur3 entre1/2/3 ; dialogue nomme solution | Trois longueurs3, largeur/profil/attaches observables ; spoilerretiré | Donorvalidator et preuves F2 concordants |
| A11 Moyen | Deux fausses cartes finales évidentes gonflent artificiellement étatssimulés | Sixcartes utiles ; finale assumée synthèse |720 permutations, pas argument de difficulté |
| A12 Majeur | Uneaction/niveau semblait une loi physique arbitraire | Classement de six phases observées, aucune durée réelle égale | Fiche expose explicitement convention |
| A13 Majeur | Refuge bas susceptible d'être noyé ensuite | Hallehaute et tousnœuds secs jusqu'à5 ; routebasse seule noyée | Graphe/texte/scénario alignés |
| A14 Majeur | Barge calculée avec cargaison encorepleine aprèslivraison | P05avant déchargement ; presse en ballast central après, amarres/guides visibles | Continuité en six poses à vérifier avec art |
| A15 Majeur | Fragments P06 pourraient servir de passerelle P07 | Morceaux decarte de maçonneriefixe, pas planches physiques | Matériau et légende explicités |
| A16 Majeur | Preuves attribuées par scènesvues : risque omission/softlock | Registre déclaratif et résolution/preuves/filenarrative atomiques | Deuxordres complets vérifiés ; runtime encore à faire |
| A17 Majeur | Sommedurées généreuse et permutations présentées comme validation | Budgethonnête42–70, cible60–90 non atteinte présumée ; gate T12 bloquant | Aucun playtest inventé ; principal risqueouvert |
| A18 Moyen | Troislieux,3 musiques,8 papiers,6 coupeseau et dérivés coûteux | Unlieu3cadrages,2 musiques,papier commun,coupe dynamique ; exclusions du manifeste | Chaque fichier classé scope/qualité |
| A19 Moyen | Replayisolé, export diagnostic, sélecteur de langue FR, fréquence variable peu utiles | HorsV1 explicitement ; fin inspectable et nouvelle partie | Navigation/sauvegarde/plan synchronisés |
| A20 Majeur | DimensionsP01, masquesP04, variantes des bâtiments incohérentes |1800×1080 et crops360×1080 ;100 px/cellule ; variants768² même pivot | Bible/manifest/planches |
| A21 Majeur | Maîtres photographiques et détails probants sousspécifiés | Sources communes, dégâts exacts, F2profil/attaches, F3jauge4, recadrages explicites | Acceptation aveugle des photos avant intégration |
| A22 Moyen | Aprèsretour/jonction le prochain objectif ambigu | Boutonobjectif persistant et deuxchoix égaux à branche | Table UX et walkthrough |
| A23 Majeur | Sauvegarde hashée mais génération enveloppe nonliée ; finincomplète possible | Égalité des générations, pending/acknowledged, completed aprèsN11 | Tests d'interruption prescrits, pas encore runtime |
| A24 Moyen | Plusieurs plans concurrents et comptages obsolètes | Autorité racine ; journal distinct ; contrat numérique unique | Scan cohérence et scripts relancés |

## Critique du rythme et du coût

Les moments réellement porteurs sont l'ordre des photos, le couplage de trois routes, l'équilibre par bras de levier et le détour partagé imposé par le brancard. Les calques restent faciles ; les durcir artificiellement nuirait à la respiration. La finale ne doit pas devenir un examen plus long que la compréhension qu'elle produit. La prose accompagne les gestes : pas de journal à lire pour extraire un chiffre enfoui, pas de longues explications de mécanique entre deux puzzles.

Le nombre de lieux et de masters est contenu, mais cinq images fonctionnelles cohérentes coûtent davantage que cinq illustrations décoratives. Leur géométrie est un poste obligatoire. L'originalité réside dans l'explication matérielle et la transformation du plancher, pas dans l'invention de chaque mécanisme. Risque de similarité générique au jeu de tuyaux P03 accepté sur une seule étape ; répétition P06 retirée.

## Simulation et résultat

Voir WALKTHROUGH pour parcours intégral, erreurs plausibles, disponibilité des preuves et retour après fermeture. verify_design.py énumère **1862 configurations de puzzles**, contrôle les deux ordres de branche,11 états de progression atteignables et21 indices. P06 distingue configurations de carte et chemins :1carte admise mais2triplets de routes. Ces contrôles prouvent des propriétés du modèle, pas la perception des assets nonproduits, ni l'absence de bugs dans un jeu qui n'existe pas.

Décision verrouillée1.1 : produire selon plan. Gates empiriques nonlevés :60–90 min, difficulté ressentie, confortmobile, plaisir, lisibilité des photos et performance. Si le premier parcours jouable confirme une durée trop courte, la cible du producteur n'est pas satisfaite : bloquer la production coûteuse et réviser de manière motivée ; ne pas annoncer un jeu commercial terminé.


## Revue critique 1.2

Les dix ajouts évitent un bloc autonome de mini-jeux après la fin : ils sont intercalés et reliés au même sauvetage. Les plus gros risques sont le caractère familier du partage de volumes, la fatigue spatiale P10/P05 et les commandes de P14. Mesurer ces points en T12. P15 reste court et explicite ; son budget est réduit à 1–2 minutes pour ne pas gonfler la durée. Les solutions multiples P10/P11/P15 sont admises. Les collisions, faux points de corde, changements de prérequis et sauvegardes anciennes ont des contrôles dédiés. Aucune promesse de 90 minutes ne découle automatiquement de 17 énigmes.
