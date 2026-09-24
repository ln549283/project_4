# Extension 1.2 — Dix énigmes et rythme global

Décision du producteur : ajouter **dix énigmes** après un retour de durée de **35–40 minutes pour les énigmes existantes**. Ce retour est une observation communiquée, pas une campagne novice documentée. Il autorise explicitement l'extension du périmètre verrouillé 1.1. Ne pas ajouter encore du contenu par anticipation.

Le jeu comporte **17 énigmes P01–P17**, plus la prise en main P00. Les IDs existants restent stables : l'ordre narratif ne suit pas l'ordre numérique. Les sept règles et solutions d'origine sont conservées. Les dix ajouts sont jouables en greybox, pas des assets finaux.

## Ordre canonique

P00 → P01 → P08 → P09 → P02 → [P03 ∥ P04] → P10 → P05 → P11 → P12 → P17 → P06 → P16 → P14 → P15 → P13 → P07 → conclusion

P03 et P04 restent les deux seules étapes interchangeables. Toutes les nouvelles énigmes font partie de la campagne. Aucun puzzle ajouté après l'épilogue. Aucun compteur, temps d'attente ou texte ajouté pour gonfler la durée.

## Courbe de rythme

| Acte | Séquences | Fonction et respiration |
|---|---|---|
| I — Retrouver le lieu | P00, P01, P08, P09, P02 | Entrée tactile douce, repérage spatial, obstacle mécanique, première déduction temporelle. N01 et la découverte du tiroir laissent respirer. |
| II — Préparer les secours | P03/P04, P10, P05, P11 | Branche libre ; contrejour court ; rangement spatial puis balance ; les amarres terminent l'acte par un geste visuel. |
| III — Accueillir et rejoindre | P12, P17, P06, P16 | Partage de l'eau, calibration courte, grand plan central, planification des navettes. Pas de chronomètre ni conséquence punitive. |
| IV — Comprendre le passage | P14, P15, P13, P07, conclusion | Pliage, appuis brefs, lumière ; trois gestes concrets préparent la synthèse finale. Aucun nouveau système après P07. |

Les difficultés dominantes ajoutées sont P09/P10/P12/P16. P15 est délibérément court : il ne doit pas être vendu comme une grosse énigme. Les animations narratives restent sautables, les objectifs visibles, les pauses libres et les brouillons sauvegardés après chaque geste stable.

## Hypothèse de durée

Les dix ajouts représentent **26–40 minutes hypothétiques**, soit **61–80 minutes d'énigmes** avec le retour actuel. L'ouverture, les transitions et la conclusion s'y ajoutent sans attente artificielle. La cible produit reste 60–90 minutes ; ce calcul n'est pas une mesure. Chronométrer séparément les ajouts en T12 avant toute annonce commerciale.

## P08 — Les façades retrouvées

- **Place :** après P01. Budget indicatif 3–4 min.
- **Situation visible :** Les bâtiments se sont détachés du socle. Les croquis de Jo montrent leurs voisinages avant la crue.
- **But :** Replacer les six bâtiments en respectant les cinq croquis.
- **Mécanique et validation :** Permutation de six bâtiments sur deux rangées de trois. Les cinq croquis décrivent des voisinages immédiats : École→Atelier, Atelier→Halle, École↓Grenier, Halle↓Infirmerie, Grenier→Clocher. Les flèches sont dessinées sur des bandeaux comparables au plateau ; la rivière fixe le bas. Toute permutation respectant ces relations est acceptée.
- **Solution de contrôle (jamais affichée au joueur) :** `{"order": [0, 1, 2, 3, 4, 5]}`.
- **Sortie narrative :** Les façades retrouvent leur place. Sous le socle, un tiroir contient les notes de restauration.
- **Information préalable :** `evidence_p08` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Les croquis indiquent des positions relatives, pas un ordre de lecture.
2. Utilisez la rivière pour distinguer les deux rangées.
3. Croisez les voisinages horizontaux avec les deux alignements verticaux.

## P09 — Le tiroir déformé

- **Place :** après P08. Budget indicatif 3–4 min.
- **Situation visible :** L'humidité a déplacé les séparateurs du tiroir. Le feuillet est retenu dans sa chemise rigide.
- **But :** Dégager la chemise vers l'ouverture à droite.
- **Mécanique et validation :** Dix pièces dans un tiroir 6×6 : la chemise horizontale 1 doit atteindre la colonne 4 de sa rangée. Les autres pièces coulissent de ±1 case dans leur rainure ; ni chevauchement ni sortie. Les positions, tailles et axes figurent dans p09.bars et p09.initial. Le témoin BFS demande 21 déplacements unitaires ; ce nombre mesure un chemin minimal, pas la difficulté humaine.
- **Solution de contrôle (jamais affichée au joueur) :** `{"positions": [4, 0, 0, 2, 1, 0, 3, 2, 0, 4]}`.
- **Témoin de gestes légaux :** `[[1, 1], [4, -1], [8, -1], [8, -1], [2, -1], [0, 1], [0, 1], [4, -1], [4, -1], [1, -1], [1, -1], [5, -1], [3, -1], [5, -1], [3, -1], [7, -1], [7, -1], [6, 1], [6, 1], [0, 1], [0, 1]]`. Pour tiroir/versement : [source, destination ou delta] ; pour navette : indices des passagers.
- **Sortie narrative :** Le tiroir s'ouvre. Les notes confirment que les photographies montrent la même crue, sans réparation entre les prises.
- **Information préalable :** `evidence_p09` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Chaque séparateur coulisse uniquement dans sa rainure.
2. Il faut libérer toute la rangée de la chemise, pas seulement sa case voisine.
3. Déplacez aussi les séparateurs éloignés : ils réservent l'espace dont les autres ont besoin.

## P10 — Les caisses au sec

- **Place :** après P03, P04. Budget indicatif 4–6 min.
- **Situation visible :** Les secours étaient rangés dans un coffre étanche. Les cales protégeaient les flacons et les vivres.
- **But :** Remplir le coffre avec les cinq lots, sans chevauchement.
- **Mécanique et validation :** Coffre 5×4 ; cinq tétriminos tournent par quarts de tour, sans réflexion. Une pièce se sélectionne, sa silhouette est prévisualisée, puis son coin de boîte englobante est posé sur une case. Toute couverture exacte sans chevauchement est acceptée : quatre dispositions. Les coordonnées locales des cinq lots sont dans p10.pieces. Retrait, rotation et annulation ne consomment rien.
- **Solution de contrôle (jamais affichée au joueur) :** `{"placements": [[3, 0, 0], [2, 2, 0], [1, 0, 1], [0, 0, 1], [0, 3, 0]]}`.
- **Sortie narrative :** Le coffre protège les lots. Il reste à équilibrer leur poids sur la barge.
- **Information préalable :** `evidence_p10` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Les cinq lots remplissent exactement le coffre.
2. Les pièces peuvent tourner, mais pas se retourner comme dans un miroir.
3. Réservez une place aux formes les moins souples avant de remplir les petits vides.

## P11 — Les amarres croisées

- **Place :** après P05. Budget indicatif 2–3 min.
- **Situation visible :** La barge sera immobilisée sous le passage. Sur le modèle, les cordages doivent rester séparés pour coulisser.
- **But :** Déplacer les quatre taquets libres jusqu'à supprimer tous les croisements.
- **Mécanique et validation :** Six taquets sur deux berges ; positions 0 et 3 fixées. Échanger deux autres taquets conserve les extrémités de toutes les cordes. Interdire les intersections hors extrémités communes, les superpositions collinéaires et le passage sur un troisième taquet. Deux dispositions sont admises. Ce sont les amarres du modèle ; aucune simulation de tension ou physique instable.
- **Solution de contrôle (jamais affichée au joueur) :** `{"order": [0, 1, 2, 3, 4, 5]}`.
- **Sortie narrative :** Les amarres sont indépendantes. La barge peut rester stable tout en accompagnant la montée de l'eau.
- **Information préalable :** `evidence_p11` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Les deux taquets fixés au quai ne bougent pas.
2. Suivez une corde à la fois jusqu'à son autre extrémité.
3. Deux cordes peuvent partager un taquet ; elles ne peuvent pas se couper entre deux taquets.

## P12 — L'eau à partager

- **Place :** après P11. Budget indicatif 3–5 min.
- **Situation visible :** Une réserve d'eau potable servait aux deux refuges. Trois récipients permettent de reconstituer le partage.
- **But :** Obtenir quatre litres dans chacun des deux grands récipients.
- **Mécanique et validation :** Récipients de capacité 8, 5 et 3 litres. Départ [8,0,0], objectif [4,4,0]. Un versement cesse uniquement lorsque la source est vide ou la destination pleine. Aucun liquide ajouté ou perdu. Les capacités, les quantités et la destination de chaque réserve sont visibles. Sept versements suffisent ; toutes les suites légales aboutissant à la cible sont admises.
- **Solution de contrôle (jamais affichée au joueur) :** `{"volumes": [4, 4, 0]}`.
- **Témoin de gestes légaux :** `[[0, 1], [1, 2], [2, 0], [1, 2], [0, 1], [1, 2], [2, 0]]`. Pour tiroir/versement : [source, destination ou delta] ; pour navette : indices des passagers.
- **Sortie narrative :** Les deux réserves sont égales. Les secours ne reposaient pas seulement sur des chemins : il fallait aussi préparer l'accueil.
- **Information préalable :** `evidence_p12` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Un versement s'arrête quand la source est vide ou la destination pleine.
2. Le petit récipient peut servir de mesure intermédiaire, puis être vidé dans un autre.
3. Cherchez à garder un reste utile dans le récipient du milieu plutôt qu'à le remplir toujours depuis zéro.

## P13 — La lanterne du quai

- **Place :** après P15. Budget indicatif 2–3 min.
- **Situation visible :** Un schéma d'Aline décrit un essai de balisage sur la maquette. Les miroirs conduisent la lumière jusqu'au quai.
- **But :** Faire passer le rayon par les trois repères puis atteindre le quai.
- **Mécanique et validation :** Plateau 6×6, entrée (-1,1) vers la droite, quai (-1,3), six miroirs en positions fixes. Chaque miroir alterne / et \. Le rayon doit traverser les trois cercles (2,3),(4,2),(1,2), puis sortir au quai. Allumer affiche uniquement le rayon actuel ; aucune correction automatique. Les miroirs se tournent au toucher. Les 64 orientations sont examinées, une valide.
- **Solution de contrôle (jamais affichée au joueur) :** `{"turns": [1, 1, 0, 1, 0, 0]}`.
- **Sortie narrative :** Le balisage rejoint le quai. Toutes les pièces du passage sont maintenant compréhensibles ; reste à reconstituer l'opération.
- **Information préalable :** `evidence_p13` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Un miroir renvoie le rayon à angle droit.
2. Les repères doivent tous être traversés, pas seulement la sortie atteinte.
3. Partez de la lanterne et vérifiez le trajet jusqu'au premier miroir qui détourne le rayon hors du plateau.

## P14 — L'escalier articulé

- **Place :** après P16. Budget indicatif 2–4 min.
- **Situation visible :** L'escalier de papier est articulé. Repliez-le dans son logement sans traverser les montants.
- **But :** Relier les deux attaches avec les quatre segments, sans collision.
- **Mécanique et validation :** Quatre segments de longueurs 2,1,2,2, départ (0,0), arrivée (4,3), logement 5×5. Chaque segment prend une direction absolue droite/bas/gauche/haut ; ses successeurs restent attachés. Les montants sont visibles, les collisions et auto-intersections interdites. Le dessin s'arrête au premier conflit. Une orientation sur 256 atteint la cible. Il s'agit du modèle articulé de l'escalier, pas de physique réelle.
- **Solution de contrôle (jamais affichée au joueur) :** `{"turns": [0, 1, 1, 0]}`.
- **Sortie narrative :** L'escalier se replie sans rompre ses attaches. La coupe du passage peut accueillir la structure mobile.
- **Information préalable :** `evidence_p14` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Chaque charnière change la direction de la partie qui la suit.
2. Les montants et les segments déjà posés sont des obstacles.
3. Comparez la place libre autour des longs segments avant d'orienter le plus court.

## P15 — Les appuis du passage

- **Place :** après P14. Budget indicatif 1–2 min.
- **Situation visible :** La coupe du modèle porte les charges et les limites des petites traverses. Les appuis ne doivent pas tomber dans les zones fragiles.
- **But :** Placer exactement trois étais pour soutenir toutes les charges.
- **Mécanique et validation :** Traverse graduée 0–10. Les culées 0 et 10 sont fixes. Choisir exactement trois étais parmi les positions libres ; 1,4,7,9 sont fragiles. Les charges en 3 et 8 exigent un appui direct. Aucun intervalle entre appuis successifs ne dépasse trois unités. Deux placements sont recevables : [3,5,8] et [3,6,8]. Une respiration de 1–2 minutes, sans formule à saisir.
- **Solution de contrôle (jamais affichée au joueur) :** `{"chosen": [3, 5, 8]}`.
- **Sortie narrative :** La coupe tient avec trois étais. Ce test explique la nécessité des appuis ; il ne révèle pas encore quelle pièce de l'atelier formait le tablier.
- **Information préalable :** `evidence_p15` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Les deux culées aux extrémités portent déjà la traverse.
2. Une charge lourde doit être au droit d'un étai ou d'une culée.
3. Après les charges lourdes, cherchez le vide qui dépasse la portée autorisée.

## P16 — La navette des secours

- **Place :** après P06. Budget indicatif 4–6 min.
- **Situation visible :** Avant l'évacuation finale, une petite navette transporte deux secouristes et deux caisses vers la halle. La barge du passage reste distincte.
- **But :** Amener les deux secouristes et les deux caisses sur l'autre rive.
- **Mécanique et validation :** Navette distincte de la barge structurelle. Jo et Aline valent chacun une unité, les deux caisses deux chacune ; capacité trois. Au moins un secouriste à bord, seuls les éléments de la rive actuelle peuvent embarquer. Tous doivent atteindre la halle. Les caisses peuvent attendre seules. Cinq traversées suffisent. Tout trajet légal est accepté, les retours et annulations toujours possibles. Aucun chrono ni noyade.
- **Solution de contrôle (jamais affichée au joueur) :** `{"bank": [1, 1, 1, 1], "boat": 1}`.
- **Témoin de gestes légaux :** `[[0, 1], [0], [0, 2], [0], [0, 3]]`. Pour tiroir/versement : [source, destination ou delta] ; pour navette : indices des passagers.
- **Sortie narrative :** La halle dispose des réserves et des secouristes. Le groupe de l'école attend encore le passage du clocher au quai.
- **Information préalable :** `evidence_p16` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Il faut toujours un secouriste à bord pour manœuvrer.
2. Le retour consomme une place lui aussi : prévoyez qui ramène la navette.
3. Les caisses peuvent attendre seules. Utilisez cette liberté pour répartir les traversées.

## P17 — Les repères de crue

- **Place :** après P12. Budget indicatif 2–3 min.
- **Situation visible :** Quatre bandes de relevé ont glissé dans leur pochette. Leurs raccords conservent la hauteur des marques communes.
- **But :** Aligner les trois paires de marques. La première bande est fixée.
- **Mécanique et validation :** Quatre bandes verticales avec décalages 0–4 ; bande 0 fixée à 0. Alignements : bande0 marque3 = bande1 marque1 ; bande1 marque2 = bande2 marque3 ; bande2 marque4 = bande3 marque2. Les paires portent à la fois un chiffre et un motif/couleur, jamais la couleur seule. Solution [0,2,1,3] ; graduations locales distinctes d'une hauteur absolue. Le niveau 4 de P06 demeure fourni par la photo F3 et n'est pas remplacé.
- **Solution de contrôle (jamais affichée au joueur) :** `{"offsets": [0, 2, 1, 3]}`.
- **Sortie narrative :** Les relevés partagent maintenant la même référence. Le niveau observé sur la photographie peut être comparé aux accès du quartier.
- **Information préalable :** `evidence_p17` est attribuée dès les prérequis, son contenu et les contraintes géométriques sont visibles dans la scène ; aucune preuve nécessaire n'est conditionnée à sa propre résolution.
- **Erreurs :** retour descriptif sur le montage présent ; pas d'emplacement correct dévoilé, pas de solution auto-complétée. Annuler et Replacer disponibles ; une tentative erronée ne retire rien.
- **Présentation :** plateau spatial dessiné depuis le contrat, états visibles et toucher/toucher ; commandes nommées pour les déplacements impossibles à exprimer par un tap seul. Pas de remplacement par un champ de code ou un texte d'état brut.

Indices progressifs :

1. Les graduations locales ne commencent pas toutes à la même hauteur.
2. Raccordez les marques identiques entre deux bandes voisines.
3. Utilisez la bande fixe comme référence, puis reportez chaque raccord au suivant.

## Continuité et risques contrôlés

Toutes les nouvelles séquences sont des restaurations/reconstitutions à l'établi. Aucune ne prétend modifier le passé, ressusciter un personnage ou découvrir un secret qu'Aline aurait caché. Les feuillets complémentaires ont été fournis avec le fonds dès le début. La navette des secours n'est pas la barge amarrée servant au passage. Les modèles réduits utilisent des unités d'exercice, pas des masses ou règles physiques réalistes appliquées à des personnes.

La mécanique P14 montre le dégagement d'un escalier ; elle n'affirme pas que le vrai escalier historique avait quatre articulations. P13 est un essai de balisage sur le modèle, sans introduire une technologie obscure indispensable à l'évacuation. P15 explique les appuis sans donner le nom du plancher ; P07 conserve sa déduction par profil, largeur et attaches.

Les pièces mobiles de P10 sont des lots protégés dans un coffre : ils ne remplacent pas les six charges et les masses de P05. P17 ne remplace pas le niveau photographique de F3. Les preuves anciennes restent accessibles aux mêmes conditions ou plus tôt que leur emploi ; les ajouts n'effacent aucun indice déjà reçu.

Sauvegardes 1.1 : vérifier l'enveloppe puis la progression originale ; conserver les étapes résolues et l'état de fin ; initialiser les dix ajouts non résolus ; retour à l'établi. `legacy_solved` exempte seulement les étapes historiques de leurs nouveaux prérequis. Avant la première écriture, conserver une copie brute `.v11_backup` des générations anciennes. Aucune nouvelle étape n'est validée artificiellement. Une nouvelle partie joue intégralement le parcours 1.2.

## Vérifications et prochaine mesure

`tools/verify_expansion.py` apporte des solveurs Python indépendants ; `tests/rules/expansion_test.gd` vérifie les règles Godot, les gestes, la campagne et la migration ; `tests/ui/expansion_ui_test.gd` instancie les dix scènes et teste geste/sauvegarde/annulation/remise à zéro/lecture seule. Les témoins ne sont pas des tests humains. Refaire T12 sur la campagne étendue avant production artistique massive.
