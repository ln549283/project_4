# Écrans, navigation, interactions et accessibilité

## Cadre commun

Format portrait logique 1080×1920, échelle de référence 3 px par dp sur une surface 360×640 dp. Les coordonnées ci-dessous sont en **dp**, hors zones système haut/bas : l'implémentation calcule un rectangle sûr et centre le contenu ; aucun bouton n'est placé dans l'encoche. Tablettes : largeur de puzzle plafonnée à 600 dp, décor étendu latéralement, aucun étirement des portiques.

Structure standard à 360×640 : barre haute y=0–56 ; objectif y=56–108 ; scène/puzzle y=108–480 ; outils locaux y=480–568 ; navigation basse y=568–640. Les scènes d'observation peuvent occuper la zone outils lorsqu'il n'y a pas de commandes. Texte 150 % : objectif refluant, zone outils extensible ; la scène devient zoomable avec commande « Agrandir », jamais recouverte par un texte. Aucun élément fonctionnel définitivement en dehors de la zone sûre. Sur appareils hauts, gagner de l'espace scénique, pas agrandir excessivement les boutons.

Touches : cible minimale 48×48 dp, espacement 8 dp ; cibles de navigation 56×56. Le geste glisser n'est qu'un raccourci. Sélection par toucher puis destination par toucher suffit pour tout. Appui long non requis. Aucune double pression chronométrée. Les objets sélectionnés ont contour double et label textuel ; pas un changement de couleur seul.

## Inventaire complet

| ID / scène | Accès | Contenu et actions | Retour / état conservé |
|---|---|---|---|
| S00 Accueil | Lancement | Logo, Continuer si sauvegarde, Nouvelle partie, Réglages, Générique | Retour système propose quitter sans supprimer |
| S01 Réglages | S00 ou pause | Texte 100/125/150 %, musique, effets, vibrations on/off, mouvement réduit, contraste renforcé, langue FR | Retour au contexte exact |
| S02 Établi | P00 et ensuite | Coffret, maquette, barge, onglets physiques vers puzzle actif ; détails décoratifs non interactifs cohérents | Vers lieux ou accueil via pause |
| S03 Archives | Dès P02 ; P01 s'y ouvre depuis coffret | Pochettes des clichés, panorama restauré, rapport, carnet | Lieu précédent |
| S04 Fenêtre | Dès P02 | Lampes passives, cadre de calques, accès P04 ; après résolution montre ponton et photo | Lieu précédent |
| S05 Panorama P01 | P00 terminé | 5 lés, cadre fixe, sélection/échange, agrandir, vérifier | Établi, brouillon conservé |
| S06 Photos P02 | P01 terminé | 5 cartes de frise, loupe, comparer deux, vérifier | Archives, ordre et zoom conservés |
| S07 Service P03 | P02 terminé | 2×3 volets, 3 départs/arrivées, traces, fiche | Établi, bits/traces conservés |
| S08 Contrejour P04 | P02 terminé | 3 onglets de calque, tourner gauche/droite, masquer, comparer | Fenêtre, rotations conservées, masquage réinitialisé visible à reprise |
| S09 Barge P05 | P03 et P04 terminés | 6 berceaux et charges, aiguille, règle, comparer, vérifier | Établi, chargement conservé |
| S10 Quartier P06 | P05 terminé | Cartes d'association puis 3×3 volets, extension clocher/quai visible en détail | Établi, associations et bits conservés |
| S11 Passage P07 | P06 terminé | Deux sous-vues A pièces, B frise ; bouton bascule après gabarit résolu | Établi ; état A/B conservé |
| S12 Carnet/preuve | À tout moment après N00 | Sections « Vu », « À comprendre », « Photos » ; inspecter, épingler une preuve, comparaison de deux | Fermer restaure vue, sélection et scroll |
| S13 Conclusion | P07 terminé | Annexe, geste Ajouter les preuves, cartel, appel, épilogue | Pause possible ; reprise au dernier segment stable |
| S14 Générique / relecture | S00 pour générique, fin pour relecture | Crédits, licences ; après fin liste P01–P07 et Explorer | Relecture en sandbox distinct ; retour fin |

Overlays O01 pause, O02 indices, O03 confirmation replacer/nouvelle partie, O04 fonctionnement, O05 sauvegarde récupérée/erreur, O06 détail image. Ils appartiennent à l'écran courant, ne constituent pas des lieux supplémentaires.

## Navigation précise

Retour Android/Échap : fermer overlay le plus haut → quitter vue détaillée → retourner au lieu parent → ouvrir pause depuis un lieu. Ne jamais quitter l'application en pleine manipulation au premier retour. Depuis accueil, un deuxième retour passe par la confirmation native/application « Quitter le jeu ? » ; sauvegarde déjà stable. Une opération de drag annulée rend l'objet à son origine et ne valide rien.

Onglets de lieux déverrouillés : « Établi », « Archives », « Fenêtre ». Pas de plan global à parcourir ; un changement de lieu prend 180 ms ou est instantané en mouvement réduit. Un nouvel onglet est signalé une seule fois par soulignement et label « Disponible ». Jamais d'icône seule à deviner.

Lorsqu'une énigme est verrouillée, son feuillet est encore replié. Le toucher affiche une raison concrète, sans faux cadenas :
- P02 : « Reconstituer d'abord le panorama. »
- P03/P04 : « Remettre les photos en ordre. »
- P05 : « Rassembler le plan de service et la silhouette. »
- P06 : « Stabiliser le chargement de la barge. »
- P07 : « Retrouver les parcours vers les refuges. »

Une énigme terminée reste inspectable. En première partie, ses réponses restent en place et ses commandes de modification sont désactivées avec « Reconstitution conservée ». Après la fin, la relecture séparée permet de la rejouer. Les preuves ne sont jamais derrière un puzzle réinitialisé.

## Compositions par puzzle

- **P01 :** cadre 320×230 dp ; mini-lés 60 dp de large, scène agrandie par loupe. Barre d'échange en bas, pas cinq détails minuscules obligatoires.
- **P02 :** frise horizontale de cinq vignettes 56×80 dp ; détail principal 312×230 dp ; bouton Comparer scinde en deux cartes verticales zoomables. Les dégâts sont visibles à 100 % du détail. Les cartes peuvent être sélectionnées depuis la frise sans fermer les détails.
- **P03 :** grille 264×176 dp, cases de 88 ; étiquettes externes 48 dp, traces à un bouton chacune. La fiche de livraison se replie, mais les couples restent résumés au-dessus.
- **P04 :** projection 280×280 dp ; onglets Calque A/B/C nommés « Gauche/Milieu/Droite » d'après leur rangement, non leur orientation correcte ; commandes de rotation tactiles sous le cadre. Masquer fonctionne par case à cocher, jamais par maintien.
- **P05 :** barge 324×150 dp ; slots de 48 dp avec séparation centrale 12 dp ; plateau d'objets 3×2 sous la barge. Une étiquette détaillée apparaît à la sélection ; elle ne recouvre pas la destination. Aiguille visible en dehors du plateau.
- **P06 :** grille 252×252 dp, cases 84 ; labels de ports extérieurs ; associations dans un tiroir supérieur accessible d'un bouton, résumé persistant des trois objectifs. Grande vue 312×312 dp en mode agrandi sans HUD secondaire ; tous les départs restent atteignables. Ne pas réduire les cases pour montrer le décor.
- **P07A :** atelier en coupe, trois poignées visibles ; gabarit cible au-dessus, objet sélectionné en silhouette comparable.
- **P07B :** frise **verticale de six rangées** pour smartphone, malgré la métaphore de six colonnes papier : niveaux 0→5 de haut en bas, 48 dp minimum par rangée. Les huit cartes sont dans un bac repliable en bas. « Rejouer » rend la frise plein écran pendant la simulation ; pause/arrêt à tout moment. Sur tablette, six colonnes autorisées si chacune garde 96 dp. L'ordre logique ne change pas.

## Indices, preuves et objectifs

Bouton « Indice » visible dans toute énigme non résolue. Première ouverture : « Une piste, sans résoudre à votre place. » puis H1. Deux boutons : Fermer et « Une autre piste » ; une confirmation légère « Afficher la piste suivante ? » évite un dévoilement involontaire. Après H3, label « Les trois pistes sont affichées », bouton suivant absent. Pas de compteur de temps, pas de baisse de note.

Le carnet n'offre aucun indice supplémentaire généré. Il affiche les preuves originales et l'objectif. Les phrases de reprise sont déterministes :
P01 Raccorder le panorama ; P02 Ordonner les cinq photos ; P03 Retrouver les livraisons ; P04 Recomposer la silhouette ; jonction Résoudre l'autre feuillet ; P05 Stabiliser la barge ; P06 Relier les groupes aux refuges ; P07 Comprendre et rejouer le passage ; conclusion Compléter le cartel.

## Accessibilité contractuelle

- Couleur doublée par motif et label dans les parcours. Contraste texte normal ≥4,5:1 ; grandes tailles et formes utiles ≥3:1. Vérifier sur rendu réel, pas seulement palette théorique.
- Texte min 16 sp équivalent, objectif 18 ; labels courts min 14 si agrandissables et non seuls porteurs d'information. Tous les paragraphes déroulent sans recouvrir un bouton.
- Pas de son exclusif : vibration et clic sont décoratifs. Indicateur d'équilibre graphique permanent ; texte « Penche à gauche / horizontal / penche à droite » actualisé après geste, pas au frame.
- Mouvement réduit supprime oscillation, travelling, parallaxe et mouvements continus ; les transitions deviennent fondus de 80 ms ou poses directes. Pas de flash ni clignotement rapide.
- Mode contraste : papier presque uni, ombres décoratives diminuées, contours graphiques renforcés, textes inchangés.
- Clavier : Tab/Shift-Tab parcours de focus, flèches pour choix local, Entrée pour action, Échap retour. Focus toujours visible. Navigation tactile en une main, pas de maintien simultané.
- Aucun discours promettant support TalkBack complet avant vérification de la version native. La structure de labels est préparée, les puzzles visuels demandent encore une adaptation pour non-voyants qui n'est pas annoncée dans cette v1.

## Microcopy système exacte

« Continuer » · « Nouvelle partie » · « Reprendre » · « Accueil » · « Réglages » · « Musique » · « Effets sonores » · « Vibrations » · « Taille du texte » · « Mouvement réduit » · « Contraste renforcé » · « Vérifier » · « Essayer » · « Rejouer » · « Annuler » · « Replacer » · « Fonctionnement » · « Agrandir » · « Comparer » · « Épingler » · « Indice » · « Fermer ».

Nouvelle partie avec progression : « Recommencer effacera la partie actuelle. Une sauvegarde de secours sera conservée. » Boutons « Garder ma partie » / « Recommencer ».
Replacer : « Replacer les éléments de cette énigme ? Vos preuves et indices resteront disponibles. »
Sauvegarde récupérée : « La dernière sauvegarde était incomplète. La précédente a été récupérée. »
Erreur deux copies : « La sauvegarde n'a pas pu être lue. Vous pouvez conserver les fichiers pour diagnostic ou commencer une nouvelle partie. »
Écriture impossible : « La progression n'a pas pu être enregistrée. Libérez de l'espace, puis réessayez. » Boutons Réessayer / Continuer sans enregistrer (confirmation explicite). Ne jamais afficher un faux succès de sauvegarde.
