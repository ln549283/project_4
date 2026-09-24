> **Version active : 1.2.** Les paragraphes 1.1 ci-dessous décrivent la base conservée ; l’extension en fin de document et [EXPANSION_1_2.md](EXPANSION_1_2.md) définissent les ajouts et prennent priorité sur les anciens nombres et prérequis.

# Écrans, navigation, interactions et accessibilité

## Cadre commun

Format portrait logique 1080×1920, échelle de référence 3 px par dp sur une surface 360×640 dp. Les coordonnées ci-dessous sont en **dp**, hors zones système haut/bas : l'implémentation calcule un rectangle sûr et centre le contenu ; aucun bouton n'est placé dans l'encoche. Tablettes : largeur de puzzle plafonnée à 600 dp, décor étendu latéralement, aucun étirement des portiques.

Structure standard à 360×640 : barre haute y=0–56 ; objectif y=56–108 ; scène/puzzle y=108–480 ; outils locaux y=480–568 ; navigation basse y=568–640. Les scènes d'observation peuvent occuper la zone outils lorsqu'il n'y a pas de commandes. Texte 150 % : objectif refluant, zone outils extensible ; la scène devient zoomable avec commande « Agrandir », jamais recouverte par un texte. Aucun élément fonctionnel définitivement en dehors de la zone sûre. Sur appareils hauts, gagner de l'espace scénique, pas agrandir excessivement les boutons.

Touches : cible minimale 48×48 dp, espacement 8 dp ; cibles de navigation 56×56. Le geste glisser n'est qu'un raccourci. Sélection par toucher puis destination par toucher suffit pour tout. Appui long non requis. Aucune double pression chronométrée. Les objets sélectionnés ont contour double et label textuel ; pas un changement de couleur seul.

## Inventaire complet

| ID / scène | Accès | Contenu et actions | Retour / état conservé |
|---|---|---|---|
| S00 Accueil | Lancement | Logo, Continuer si sauvegarde, Nouvelle partie, Réglages, Générique | Retour système propose quitter sans supprimer |
| S01 Réglages | S00 ou pause | Texte 100/125/150 %, musique, effets, vibrations on/off, mouvement réduit, contraste renforcé ; FR uniquement, aucun sélecteur de langue | Retour au contexte exact |
| S02 Établi | P00 et ensuite | Coffret, maquette, barge, onglets physiques vers puzzle actif ; détails décoratifs non interactifs cohérents | Vers lieux ou accueil via pause |
| S03 Archives | Dès l’ouverture de P02 ; P01 s'y ouvre depuis coffret | Pochettes des clichés, panorama restauré, rapport, carnet | Lieu précédent |
| S04 Fenêtre | Dès P02 | Lampes passives, cadre de calques, accès P04 ; après résolution montre ponton et photo | Lieu précédent |
| S05 Panorama P01 | P00 terminé | 5 lés, cadre fixe, sélection/échange, agrandir, vérifier | Établi, brouillon conservé |
| S06 Photos P02 | P01 terminé | 5 cartes de frise, loupe, comparer deux, vérifier | Archives, ordre et zoom conservés |
| S07 Service P03 | P02 terminé | 2×3 volets, 3 départs/arrivées, traces, fiche | Établi, bits/traces conservés |
| S08 Contrejour P04 | P02 terminé | 3 onglets de calque, tourner gauche/droite, masquer, comparer | Fenêtre, rotations conservées, masquage réinitialisé visible à reprise |
| S09 Barge P05 | P03 et P04 terminés | 6 berceaux et charges, aiguille, règle, comparer, vérifier | Établi, chargement conservé |
| S10 Quartier P06 | P05 terminé | Carte de crue, deux fragments, neuf nœuds et trois tracés ; extension clocher/quai visible | Établi, eau, fragments et routes conservés |
| S11 Passage P07 | P06 terminé | Deux sous-vues A pièces, B frise ; bouton bascule après gabarit résolu | Établi ; état A/B conservé |
| S12 Carnet/preuve | À tout moment après N00 | Sections « Vu », « À comprendre », « Photos » ; inspecter, épingler une preuve, comparaison de deux | Fermer restaure vue, sélection et scroll |
| S13 Conclusion | P07 terminé | Témoignage déjà disponible, geste Ajouter les preuves, cartel, appel, épilogue | Pause possible ; reprise au dernier segment stable |
| S14 Générique / exploration | S00 pour générique, fin pour exploration | Crédits, licences ; après fin Explorer les scènes résolues | Exploration en lecture seule ; retour fin |

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

Une énigme terminée reste inspectable. En première partie, ses réponses restent en place et ses commandes de modification sont désactivées avec « Reconstitution conservée ». Après la fin, une nouvelle partie confirmée permet de rejouer la campagne. Les preuves ne sont jamais derrière un puzzle réinitialisé.

## Compositions par puzzle

- **P01 :** cadre 320×192 dp ; mini-lés 60 dp de large, scène agrandie par loupe. Barre d'échange en bas, pas cinq détails minuscules obligatoires.
- **P02 :** frise horizontale de cinq vignettes 56×80 dp ; détail principal 312×230 dp ; bouton Comparer scinde en deux cartes verticales zoomables. Les dégâts sont visibles à 100 % du détail. Les cartes peuvent être sélectionnées depuis la frise sans fermer les détails.
- **P03 :** grille 264×176 dp, cases de 88 ; étiquettes externes 48 dp, traces à un bouton chacune. La fiche de livraison se replie, mais les couples restent résumés au-dessus.
- **P04 :** projection 280×280 dp ; onglets Calque A/B/C nommés « Gauche/Milieu/Droite » d'après leur rangement, non leur orientation correcte ; commandes de rotation tactiles sous le cadre. Masquer fonctionne par case à cocher, jamais par maintien.
- **P05 :** barge schématique 320×150 dp, pivot et intervalles fidèles −3,−2,−1,+1,+2,+3 (double espace central). Les petits ancrages ne sont pas des boutons obligatoires. Sélectionner une charge dans le plateau 3×2 puis un des six boutons de destination 3×2, chacun 96×48 dp séparé de 8 dp : G.ext/G.mil/G.int/D.int/D.mil/D.ext, labels complets au focus. Retour plateau via emplacement fantôme. Aiguille toujours visible. Les boutons reproduisent les labels de la barge ; aucune distorsion des bras pour agrandir une cible.
- **P06 :** carte 900×1080source, fenêtre 300×360 dp avec zoom commandé ×2 et boutons de déplacement 48 dp (pas de pincement requis). Eau 0–5 par choix dans tiroir, fragments par sélection/emplacement, groupe par 3 boutons. Les points trop proches à échelle globale sont inspectables via liste « Prochains lieux » de boutons 48 dp des voisins du nœud courant, sans filtrer les erreurs de marches/eau : le joueur décide. Sélectionner un lieu atteint permet tronquer le trajet. Liste des quatre emplacements de fragments avec noms des extrémités. Carte et liste ont même état ; aucun minuscule hotspot obligatoire.
- **P07A :** atelier en coupe, trois poignées visibles ; gabarit cible au-dessus, objet sélectionné en silhouette comparable.
- **P07B :** frise **verticale de six rangées** pour smartphone, malgré la métaphore de six colonnes papier : niveaux 0→5 de haut en bas, 48 dp minimum par rangée. Les six cartes sont dans un bac repliable en bas. « Rejouer » rend la frise plein écran pendant la simulation ; pause/arrêt à tout moment. Sur tablette, six colonnes autorisées si chacune garde 96 dp. L'ordre logique ne change pas.

## Indices, preuves et objectifs

Bouton « Indice » visible dans toute énigme P01–P07 non résolue ; absent de P00. Première ouverture : « Une piste, sans résoudre à votre place. » puis H1. Deux boutons : Fermer et « Une autre piste » ; une confirmation légère « Afficher la piste suivante ? » évite un dévoilement involontaire. Après H3, label « Les trois pistes sont affichées », bouton suivant absent. Pas de compteur de temps, pas de baisse de note.

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

## Cadre présent et objectifs verrouillés1.1

S02–S04 sont trois cadrages du même espace municipal : établi, documents sur l'établi, fenêtre de cette pièce. S03 réutilise le fond de l'établi et ui_paper_panel ; ne pas fabriquer un meuble/salle d'archives supplémentaire. Onglets directs conservés, aucune marche virtuelle.

Objectifs persistants, bouton « Continuer le travail » ouvrant la vue concernée : P00 Ouvrir le coffret ; P01 Raccorder le panorama ; P02 Retrouver l'ordre des photographies ; après P02 deux boutons égaux « Chemins de service » et « Contrejour » ; après une branche, bouton vers l'autre ; après jonction Stabiliser la cargaison ; après P05 Retrouver les chemins vers les refuges ; après P06 Expliquer le passage vers le quai ; après P07 Ajouter les preuves au cartel ; après fin Explorer / Nouvelle partie. Aucun objectif n'exige de reconnaître un objet décoratif non signalé.

O02 contient exactement trois indices par P01–P07, compteur 0–3, révélation par toucher et confirmation textuelle de demande ; pas de quatrième aide ni auto-solution. P00 possède seulement instruction gestuelle visible. O05 : réessayer sauvegarde, récupération explicite, nouvelle partie confirmée si nécessaire ; aucun bouton export diagnostic fictif.

Frise P07 : rangées 48 dp +8 dp d'espacement, scroll vertical si nécessaire ; plateau six cartes dans tiroir séparé. L'ouverture du tiroir conserve le niveau sélectionné. Aucun bouton masqué à texte 150%. Ces minima priment sur les rectangles schématiques des planches studio.


## Vues additionnelles 1.2

Dix routes `p08`–`p17` vers `scenes/puzzles/pXX.tscn`. Titres et objectifs dans les contrats. Navigation de l'établi selon `campaign_order` et les prérequis, pas le numéro d'ID. Chaque plateau expose son état spatial ; aucun input de solution textuel. Réussite → sauvegarde → établi → texte bref → objectif suivant. Les puzzles résolus sont consultables depuis l'exploration finale. Pour une campagne 1.1 migrée, le bouton Établi donne accès aux nouveaux ateliers.

Le contrôleur commun préserve le défilement pendant les gestes, propose Annuler/Replacer/Fonctionnement/Indice/Carnet/Retour, et interdit la mutation des étapes résolues. P09 : sélection puis flèches ; P10 : lot, rotation, ancrage ; P11 : échange de taquets ; P12 : source puis destination ; P13 : miroir puis Allumer ; P14 : orientation des segments ; P15 : choix des appuis ; P16 : équipage puis Traverser ; P17 : déplacements verticaux. Critères à recontrôler sur appareil : absence de glissement involontaire, lisibilité à 150 %, cibles et absence de défilement horizontal.
