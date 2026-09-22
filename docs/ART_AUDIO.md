# Direction artistique et sonore — contrat de fabrication

## Image cible

Un objet artisanal que l'on aurait envie de poser sur une table : papier ivoire, aplats d'encre, fibres peu contrastées, plis usés, petites attaches de cuivre. Une ville reconnaissable par ses toits, son linge et ses façades plutôt que par une surcharge de bibelots. L'impression premium doit venir de la cohérence, de la qualité des compositions et de la réponse des objets au doigt.

Pas de photoréalisme, pas de 3D plastique, pas de contours épais façon jeu de tri, pas de texte décoratif illisible généré dans une image. Les décors peuvent utiliser illustration raster originale ; **toute géométrie porteuse d'une solution est dessinée depuis les données**. Les éléments procéduraux sont habillés ensuite sans changer leur topologie.

## Palette et typographie

| Usage | Couleur de départ | Règle |
|---|---|---|
| Papier principal | #F1E8D5 | Fond clair, grain discret 3–5 % |
| Texte / contours | #26333C | Priorité lisibilité |
| Eau et routes secondaires | #476D73 | Toujours accompagné de motif si fonctionnel |
| Cuivre / attaches | #A86546 | Décor et prises, jamais texte long sur ivoire |
| Signal / sélection | #C56A53 | Contour double en plus de teinte |
| Papier ombré | #C4B9A4 | Ombres fixes et creux |
| Refuge / confirmation | #486B53 | Icône et texte de réussite associés |

Couleurs de départ, contrastes finaux mesurés sur exports. Le mode contraste remplace texture et papier ombré par aplats, garde texte foncé. Police UI choisie : Noto Sans, regular/semibold ; titres : Noto Serif, medium. Sources de police et licences à intégrer au registre avant build distribué ; aucun chargement web. Pas de multiplication de polices manuscrites. La signature d'Aline est un tracé original simple, jamais une signature réelle copiée.

## Caméra et composition

Trois décors 1080×1920, zone sûre centrale 936 px ; marge latérale décorative 72 px. Les vues de lieux utilisent une légère perspective de table, les vues puzzles une projection orthographique stricte. Le passage d'une vue à l'autre est un zoom de 250 ms, fondu en mouvement réduit. La maquette n'est jamais tournée librement : nord fixe pour ne pas modifier le sens des contraintes.

- Établi : lumière de gauche, coffret au centre bas, outils en périphérie, barge dans berceau à droite. Le plancher de l'atelier est visible dès le début mais sa prise devient évidente après P06 par ouverture du plan central, sans apparition magique.
- Archives : bois mat, cinq photos et pochette calque ; lieu plus plat et tranquille, surfaces où épingler des preuves.
- Fenêtre : lumière diffuse blanche, trois cadres de calque, gouttes à peine mobiles hors zone de projection. Aucun filtre sépia qui effacerait les indices.

Dessiner séparément décor, ombres, objets actifs, preuves et labels. Aucun hotspot obligatoire incrusté dans le fond et oublié dans l'inventaire. Quand la maquette se déplie, les cases fonctionnelles restent dans leur rectangle interactif et les maisons décoratives se déploient autour, pas sur les chemins.

## Identité des bâtiments et personnages

- Atelier : toit deux pans vert foncé, façade trois travées, fenêtre ronde, plancher trois segments rigidement liés ; couture et quatre points d'appui reconnaissables dans F2/P04/P07.
- École : deux fenêtres hautes, auvent rayé, escalier extérieur ; identique sur tous clichés.
- Clocher : petite cloche visible, escalier sans ambiguïté, plateforme de rassemblement ; pas de symbolique religieuse nécessaire à la compréhension.
- Quai haut : parapet continu, trois bollards ; nettement au-dessus des repères d'eau.
- Halle : entrée large et plain-pied ; pictogramme de brancard.
- Grenier : étage haut, échelle extérieure ; pictogramme de cartons secs.
- Infirmerie : croix de soin simple non assimilée à un emblème protégé ; préférer bande et silhouette de sac médical dans le jeu.
- Réfectoire : bol et couvert ; pharmacie : flacon ; archives : cartons ; origines P03 parfois simples enseignes schématiques sans nouveau décor.

Nelle : silhouette de papier bleu nuit, cheveux attachés, manche ocre. Aline : silhouette vert rivière, cheveux courts grisonnants, tablier cuivre. Jo : silhouette ivoire/graphite avec veste longue. Visages stylisés deux ou trois traits, pas de portrait photoréaliste. Figurants par groupes, aucun enfant blessé ou expression de panique.

## Production des assets

`design/assets.csv` est la liste de commande. Chaque ligne a un ID stable, un chemin final, un format, une taille/durée, un usage, une méthode et un critère de QA. Tous les livrables runtime sont à fabriquer ; les SVG de `design/plates/` sont uniquement des gabarits de logique.

Pipeline :
1. Appliquer palette et géométrie de référence aux trois fonds et à un bâtiment témoin.
2. Produire les sprites bâtiments cohérents puis leurs variantes de crue.
3. Construire les éléments fonctionnels à partir du JSON, exporter les masques/chemins à résolution exacte.
4. Composer les clichés depuis **les mêmes** éléments d'architecture ; ne pas générer séparément cinq scènes dont les fenêtres changeraient involontairement.
5. Ajouter grain et irrégularités dans une couche décorative sans déplacer les raccords.
6. Vérifier les captures à taille smartphone et 150 % texte ; corriger avant d'intégrer les autres variantes.
7. Inscrire auteur, date, provenance, droits et chemin source dans `assets/LICENSES.csv` avant distribution.

L'illustration raster de fond peut être produite avec un outil de génération d'images si disponible, puis cohérente avec les assets réutilisables. Aucun générateur n'est chargé d'inventer les dégâts, les longueurs de travée, les bords P01, les cases P03/P06 ou la silhouette P04. Les retouches d'une image générée doivent respecter le pipeline d'édition autorisé dans la session de production.

## Animations commandées

| ID | Sujet | Durée et états | Implémentation |
|---|---|---|---|
| anim_box | Coffret | fermé → attaches ouvertes → déplié, 600 ms | 3 plans et pivots 2D |
| anim_flap | Volet | face0↔face1, 220 ms | scale X jusqu'à 0, changer face, revenir ; ombre synchronisée |
| anim_paper_pick | Objet sélectionné | léger soulèvement 120 ms | translation 4 px + ombre, pas d'oscillation permanente |
| anim_balance | Barge | angle −8°…+8°, amorti 300 ms | valeur dérivée du moment, pas de corps physique |
| anim_water | Ambiance | boucle 8 s très faible amplitude | 2 bandes, option mouvement réduit |
| anim_floor | Plancher transféré | retrait puis aperçu cible, 600 ms | trajectoire simple contrôlée, annulable |
| anim_replay | Six phases | 2–3 s chacune, maximum 18 s | tableaux d'état, avance manuelle disponible |
| anim_epilogue | Exposition | 8 s de petites silhouettes | positions clés, aucun lip-sync |
| anim_feedback | Raccord/contradiction | 250 ms | trait/label, aucun flash |

Pas de spritesheet de personnage à huit directions, simulation de tissu ou éclairage dynamique coûteux. Les états de logique existent indépendamment du tween. En mouvement réduit, montrer les poses stables avec fondus très courts.

## Son

Le mix doit évoquer une pièce calme. Aucune musique triomphale de victoire, aucun son strident d'erreur. Effets matériels précis, volume doux, maximum deux variations par action pour éviter répétition mécanique. Les énigmes n'exigent ni oreille musicale ni identification de bruit.

Musique originale composée pour le jeu, trois morceaux :
- **M01 L'atelier**, boucle 100 s, piano feutré très espacé et souffle harmonique, environ 68 pulsations/min sans percussion marquée.
- **M02 Les passages**, boucle 110 s, cordes pincées discrètes et motif suspendu, densité modérée ; ne pas caler la logique sur le tempo.
- **M03 La rive ouverte**, 85 s, reprise du motif initial plus lumineuse, fin musicale propre utilisable dans générique.

Ambiances stéréo : intérieur/pluie lointaine (45 s), fenêtre (40 s), exposition calme (35 s), sans voix compréhensibles. Source master WAV 48 kHz/24 bit, runtime Ogg Vorbis pour boucles ; petits SFX mono WAV 48 kHz/16 bit. Cibles mix de travail : musique autour de −23 LUFS intégrés, effets ajustés perceptivement sans pic supérieur à −3 dBFS, master sans clipping. Tester casque et haut-parleur téléphone, pas de niveau « certifié » sans mesure.

Événements SFX : sélectionner papier, déposer, retourner volet (deux variantes), attache cuivre, coffret, rotation calque, glisser photo, caisse posée (deux), équilibre atteint, bois posé, eau de phase (très discret), détail de contradiction (papier sec), validation (accord court), combiné téléphone, page de fin. Vibration optionnelle 10–20 ms sur pose/raccord, aucune répétition en erreur.

Transitions : M01 au début ; M02 dès la jonction P03/P04 ; M03 à la validation P07. Crossfade 1,2 s, pause app stop/suspend, reprise au même bus sans empilement. Le mute est mémorisé immédiatement.

## Icone et supports commerciaux

Icône : maison en papier dont le plancher devient une passerelle, sur eau bleu nuit ; silhouette lisible à 48 px, aucun texte. Préparer carré 1024² source, couches adaptive foreground/background/monochrome et variante store. Les formats de livraison store doivent être vérifiés lors du release ; le manifeste fournit des tailles de travail, pas une affirmation des politiques futures.

Visuel horizontal de travail 1024×500 : maison, passerelle et titre à gauche, marge de recadrage. Captures store issues **du jeu réel final**, jamais d'une maquette laissant croire à une fonctionnalité absente : panorama, routes, barge, plancher. Description provisoire fixée : « Dépliez une ville de papier et reconstituez un sauvetage oublié. Observez, reliez et transformez les pièces d'une maquette dans une aventure d'énigmes sans publicité, jouable hors ligne. » N'annoncer durée et langues qu'après vérification.
