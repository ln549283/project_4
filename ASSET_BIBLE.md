# ASSET BIBLE — Les Rives pliées — conception 1.2

> **Essai artistique limité à P13 :** le [vertical slice de la lanterne](docs/VERTICAL_SLICE.md) explore un atelier nocturne plus réaliste, le laiton patiné et une lumière animée. Cette variation autorisée pour le test ne généralise pas cette DA aux autres scènes. La production massive reste suspendue.

**Contrat de fabrication verrouillé. Aucun asset final n'existe encore.** Les planches de design sont des schémas studio, pas des illustrations commerciales. `design/assets.csv` contient exactement les mêmes entrées que les tableaux ci-dessous. required_v1 obligatoire ; ignore_v1 interdit de fabrication pour cette version. Les sources font partie de la livraison même si elles ne sont pas exportées dans le jeu.

## Direction artistique

Livre animé tactile, matériaux modestes travaillés avec précision. Papier ivoire #F1E8D5, graphite #26333C, rivière #476D73, feuillage #74856C, cuivre #A86546. Accent corail #B66A59 pour détail narratif, jamais seul code d'erreur. Texte graphite sur ivoire ; tester contraste réel à l'intégration, viser4,5:1 pour corps et3:1 pour éléments graphiques fonctionnels. Pas de plastique brillant, outline noir uniforme, photoréalisme disparate, décor gothique ni catastrophe spectaculaire.

Caméra des puzzles orthographique frontale ; maquette décorative orthographique avec élévation douce30°, jamais perspective utilisée pour déduire une longueur. Éclairage fixe haut gauche, ombre douce bas droite, ombres sur calques séparés, pas d'ombre peinte qui change une silhouette logique. Grain papier basse fréquence discret ; aucune fibre/rayure interprétable comme une preuve. Découpes irrégulières permises uniquement hors raccords fonctionnels.

Le présent se déroule dans une salle municipale. Établi : bois clair, outils de papier rangés aux bords, surface centrale vide et calme ; fenêtre : cadre ivoire et ciel gris doux, aucune rue narrative supplémentaire. Documents : fond de l'établi recadré + panneau papier commun. Finale : même maquette, socle d'exposition et silhouettes, pas de nouveau panorama architectural.

Bâtiments : atelier cuivre/3 baies et plancher démontable ; école ivoire/2 grandes fenêtres et escalier extérieur ; clocher étroit/toitpointu et cloche ; quaihaut muretlong ; hallehaute grand toit bas/porte large sans marches ; grenier haut à deux étages ; infirmerie petit porche et pictogramme de lit ; réfectoire auvent et enseigne ronde. Ces signatures identiques dans maquette, panorama, photos et pictos. Aucun symbole culturel à déchiffrer.

Personnages en silhouettes de papier, sans visage détaillé : Nelle veste vertgrisé et cheveuxcourts ; Aline manteaucuivre et cheveuxclairs attachés ; Jo tabliergraphite ; enfants trois silhouettes de tailles distinctes avec deux accompagnateurs ; groupeinfirmerie deux porteurs/brancard ; archives deux porteurs/caisses. Pas de spritesheets de marche : translation/poses uniques suffisent. L'épilogue réutilise ces sources.

## Hiérarchie et ordre de fabrication

**Héros :** plateau/atelier/plancher, fond de l'établi, panorama maître, scène historique et cinq photos, icône/visuelcommercial. Temps de finition prioritaire : cohérence des volumes, matière, lisibilité des preuves et émotion du transfert. Les cinq photos sont un seul système de composition ; ne pas les générer séparément. Accepter les masters fonctionnels avant leurs dérivés.

**Secondaires :** autres bâtiments, personnages, coffret, charges, fenêtre, accessoires. Même palette/pivots, détails limités à leur taille effective ; pas de vue supplémentaire pour les mettre en valeur.

**UI :** labels rendus par moteur, icônes96², panneaux/buttons9slice, focus, choix sélectionné, polices et wordmark. Motifs de routes et hachures indépendants de la couleur. NotoSans regular/semibold pour UI et corps ; NotoSerif medium pour titre/cartel. Corps18 sp, jamais sous16 sp pour preuve ; titres24 sp. Réglages100/125/150%. Licences exactes à inclure depuis les distributions obtenues.

**Variantes :** dégâts photo, escalier, atelier sans plancher, icônesadaptatives. Dériver des masters, jamais redessiner l'objet. Même canvas768², même pivot bas centre(384,704), même échelle. Seul attribut indiqué change.

**Mécaniques :** masques, ports, motifs, carte P06, fragments, coupe, crops et captures. Produire depuis données/vectoriel ; aucune génération approximative. Le temps artistique va à l'habillage autour d'une géométrie stable.

## Sources, exports et cohérence

Sources raster `.kra` avec calques nommés `base`, `functional`, `damage`, `shadow`, `decor`; sources vectorielles SVG unités pixels/viewBox explicite ; musique/SFX masters WAV48kHz24 bit. Runtime PNG sRGB8 bit RGB/RGBA alpha droit, pas de bordblanc prémultiplié ; SVG simples sans fontes distantes/filtres lourds. Audio selon ART_AUDIO. Pas de JPEG pour raccords ou transparence. Source au moins taille indiquée ; exports aux tailles du manifeste. Atlas max2048², padding4 px ; pas de crop automatique d'un canvas pivot partagé.

Chaque asset livré avec auteur, date, source/licence et dépendances dans `art_src/ASSET_PROVENANCE.csv`. Aucun ID de solution/nom de fichier dans les pixels. Les textes/frises/chiffres informatifs sont rendus par UI ; le raster laisse l'espace correspondant. Les masters source-only ne sont pas chargés dans le runtime.

Pivots : bâtiments/variantes (384,704)/768² ; silhouettes (192,704)/384×768 ; accessoires768² centre(384,384), sauf couvercle charnière(384,120), aiguille(384,640) ; calques(350,350)/700². Les latches utilisent la même texture, pivot centre. Séparer plancher/toit/porte et leur ombre du bâtiment pour retrait ; pas de doublon peint dans base. Barge équilibrée pivot centre ; amarrage et ballast en finale dérivés des mêmes props, jamais une nouvelle physique.

## Géométrie inviolable par énigme

| Étape | Instruction de fabrication et contrôle |
|---|---|
| P01 | Master1800×1080, cinq bandes360×1080 dans l'ordre JSON. Cadre même ratio ; affichage320×192 dp. Deux tracés de raccord distincts par couture selon signatures ; continuité pixel parfaite. Aucun numéro d'ordre visible. |
| P02 | F4/F1/F5/F2/F3 : matrice de dégâts de puzzles.json exacte. Un null signifie hors cadre, jamais intact implicite. Même lieu, cinq cadrages justifiés ; dégâts sur auvent réfectoire, vitre école, enseigne réfectoire, cheminée grenier. Les preuves requises restent visibles au détail312×230 dp et zoom sans deviner un pixel. |
| P03 | Faces512², ports milieu des côtés, deux courbes sans croisement suivant couplesJSON. Courbes32 px, marges distinctes, aucune connexion décorative ; usages P03 seulement. |
| P04 | Masques700² = grille7×7 à cellules100 px. Rotation quartdetour centre350,350 ; union cible exacte. Forme tablier/quatre appuis identique à la silhouette F2 ; texture ne modifie pas masque. |
| P05 | Berceaux aux x relatifs −3,−2,−1,+1,+2,+3, donc intervallecentral double. Pas de6 cases équidistantes ! Arceaux bas sur4 places externes, lanterne/presse hautes ; masses1–6 sous formejetons + chiffreUI. Boutonsalternatifs SCREENS_UX préservent lisibilité sans déformer les bras. |
| P06 | Carte900×1080, coordonnéesJSON et noms identiques. Chaque croisement sans nœud montre pontgraphique/saut de trait. Marches par échelons+pictogramme+texte. Seuil4 sur I–H ; autres6. Blancs2ou3 coutures, aucun détail visuel ne permet distinguer à lui seul le bon emplacement parmi les2compatibles. Eau0–5 pilotée par UI, carte schématique non métrique. |
| P07 | Porte/toit/plancher tous portée3 ; portelargeur1/gonds, toitlargeur2/profilV/pas attaches, plancherlargeur2/plat/attachesappariées. Mêmes métriques en inspection et F2. Coupe720×480 avec graduations0–5 ; seuils de PUZZLES représentés, eau séparée. Six cartes seulement. |

Photographies : composer en2400×1800 source et exporter1200×900. Disposer les détails obligatoires dans la zonecentrale x120–1080/y90–810 de l'export ; chaque dégât visible occupe au moins96×96 px, évitant lecture au pixel. Pour les observations null, recadrer réellement le bâtiment ou masquer par premier plan opaque ; ne pas couvrir juste le dégât par une étiquette. F2 comporte un détail source de la passerelle en vue troisquarts où profil/largeur/attaches sont tous discernables ; `f2_detail` est extrait de cette même scène source, pas une nouvelle preuve inventée. F3 échelle verticale0–5, eau alignée sur4 ; `f3_gauge_detail` même source et mêmes valeurs. L'eau ne masque jamais l'état des dommages requis. Les silhouettes de F3 au quai documentent l'arrivée réelle passée ; elles ne sont pas l'état courant de la maquette P06.

Photo/carton P04 : le contour exact7×7 est celui d'une vue latérale de la structure ; l'inspection de F2 présente cette projection latérale dans un voletdétail issu du même assemblage3Dsymbolique de papier. Largeur/attaches visibles dans la vue d'ensemble troisquarts, sans changer le nombre d'appuis. Aucune ombre plausible dessinée au hasard ne peut remplacer le masque contractuel.

## Réutilisations et exclusions

bg_archive remplacé par bg_workbench recadré ; tous paper_* remplacés par ui_paper_panel + texte ; refuge_* par building_* + labels de destination ; tide_0..5 par tide_cutaway et état d'eau ; les deux actions factices retirées. music_passages retiré, music_atelier continue jusqu'à P07. sfx_flap_b/crate_b retirés ; calque_rotate/photo_slide/last_page réutilisent paper_pick/drop ; water_step sans effet distinct. Ne pas fabriquer les fichiers ignore_v1. Animations et étatsUI procéduraux ne sont pas des fichiers raster manquants.

## Acceptation des assets

Revue à taille effective sur téléphone, en gris, texte 150%, mouvement réduit. Photographies : audit matrice aveugle par personne ne connaissant pas l'ordre ; chaque dégât observable sans aide. P01 coutures/P04masques/P06carte vérifiés contre données, variantes superposées aux masters pour détecter dérive. Vérifier alpha, pivots, contraste, taille mémoire et licences avant passage planned→approved. Échec fonctionnel interdit l'intégration même si l'image est belle.

## Inventaire exhaustif

Chaque ligne est une livraison ou une exclusion explicite. Les colonnes méthode, critères et source détaillés sont également conservées dans `design/assets.csv`. Les chemins `art_src` sont des masters non exportés ; les chemins `assets` désignent les fichiers à intégrer. Capturesstore issues exclusivement du build final. Les formatsstore indiqués sont des formats de travail à reconfirmer au lotrelease.

### Assets héros

| ID | Scope | Fichier | Dimensions/format | Usage |
|---|---|---|---|---|
| bg_workbench | required_v1 | assets/backgrounds/workbench.png | 1080x1920 RGBA | Établi, coffret et périphérie |
| building_atelier | required_v1 | assets/architecture/atelier.png | 768x768 RGBA | atelier |
| prop_floor | required_v1 | assets/props/floor.png | 768x768 RGBA | Objet floor |
| photo_f4 | required_v1 | assets/puzzles/p02/f4.png | 1200x900 RGB | Photo F4 |
| photo_f1 | required_v1 | assets/puzzles/p02/f1.png | 1200x900 RGB | Photo F1 |
| photo_f5 | required_v1 | assets/puzzles/p02/f5.png | 1200x900 RGB | Photo F5 |
| photo_f2 | required_v1 | assets/puzzles/p02/f2.png | 1200x900 RGB | Photo F2 |
| photo_f3 | required_v1 | assets/puzzles/p02/f3.png | 1200x900 RGB | Photo F3 |
| store_icon_master | required_v1 | assets/store/icon_master.png | 1024x1024 PNG | Support commercial icon_master |
| store_feature_graphic | required_v1 | assets/store/feature_graphic.png | 1024x500 PNG | Support commercial feature_graphic |
| panorama_master | required_v1 | art_src/panorama_master.kra | 1800x1080 RGBA layers | Master unique des cinq lés |
| maquette_board | required_v1 | assets/props/maquette_board.png | 1080x1200 RGBA | Plateau commun début/fin et support des bâtiments |
| shared_town_scene | required_v1 | art_src/shared_town_scene.kra | 2400x1800 RGBA layers | Composition maître historique des cinq photographies |

### Assets secondaires

| ID | Scope | Fichier | Dimensions/format | Usage |
|---|---|---|---|---|
| bg_archive | ignore_v1 | assets/backgrounds/archive.png | 1080x1920 RGBA | Meuble et surfaces de comparaison |
| bg_window | required_v1 | assets/backgrounds/window.png | 1080x1920 RGBA | Fenêtre et zone de projection |
| building_ecole | required_v1 | assets/architecture/ecole.png | 768x768 RGBA | ecole |
| building_clocher | required_v1 | assets/architecture/clocher.png | 768x768 RGBA | clocher |
| building_quai_haut | required_v1 | assets/architecture/quai_haut.png | 768x768 RGBA | quai_haut |
| building_halle | required_v1 | assets/architecture/halle.png | 768x768 RGBA | halle |
| building_grenier | required_v1 | assets/architecture/grenier.png | 768x768 RGBA | grenier |
| building_infirmerie | required_v1 | assets/architecture/infirmerie.png | 768x768 RGBA | infirmerie |
| building_refectoire | required_v1 | assets/architecture/refectoire.png | 768x768 RGBA | refectoire |
| figure_nelle | required_v1 | assets/props/nelle.png | 384x768 RGBA | Silhouette nelle |
| figure_aline | required_v1 | assets/props/aline.png | 384x768 RGBA | Silhouette aline |
| figure_jo | required_v1 | assets/props/jo.png | 384x768 RGBA | Silhouette jo |
| figure_children_group | required_v1 | assets/props/children_group.png | 384x768 RGBA | Silhouette children_group |
| figure_nurse_group | required_v1 | assets/props/nurse_group.png | 384x768 RGBA | Silhouette nurse_group |
| figure_archive_group | required_v1 | assets/props/archive_group.png | 384x768 RGBA | Silhouette archive_group |
| prop_box_closed | required_v1 | assets/props/box_closed.png | 768x768 RGBA | Objet box_closed |
| prop_box_lid | required_v1 | assets/props/box_lid.png | 768x768 RGBA | Objet box_lid |
| prop_box_base | required_v1 | assets/props/box_base.png | 768x768 RGBA | Objet box_base |
| prop_latch | required_v1 | assets/props/latch.png | 768x768 RGBA | Objet latch |
| prop_paper_tab | required_v1 | assets/props/paper_tab.png | 768x768 RGBA | Objet paper_tab |
| prop_barge | required_v1 | assets/props/barge.png | 768x768 RGBA | Objet barge |
| prop_balance_pointer | required_v1 | assets/props/balance_pointer.png | 768x768 RGBA | Objet balance_pointer |
| prop_roof | required_v1 | assets/props/roof.png | 768x768 RGBA | Objet roof |
| prop_door | required_v1 | assets/props/door.png | 768x768 RGBA | Objet door |
| prop_brace | required_v1 | assets/props/brace.png | 768x768 RGBA | Objet brace |
| prop_rope | required_v1 | assets/props/rope.png | 768x768 RGBA | Objet rope |
| prop_telephone | required_v1 | assets/props/telephone.png | 768x768 RGBA | Objet telephone |
| prop_exhibition_plinth | required_v1 | assets/props/exhibition_plinth.png | 768x768 RGBA | Objet exhibition_plinth |
| p01_frame | required_v1 | assets/puzzles/p01/frame.png | 1800x1080 RGBA | Ancres fixes du panorama |
| cargo_lantern | required_v1 | assets/puzzles/p05/lantern.png | 384x384 RGBA | Charge lantern |
| cargo_medicine | required_v1 | assets/puzzles/p05/medicine.png | 384x384 RGBA | Charge medicine |
| cargo_food | required_v1 | assets/puzzles/p05/food.png | 384x384 RGBA | Charge food |
| cargo_tools | required_v1 | assets/puzzles/p05/tools.png | 384x384 RGBA | Charge tools |
| cargo_dye | required_v1 | assets/puzzles/p05/dye.png | 384x384 RGBA | Charge dye |
| cargo_press | required_v1 | assets/puzzles/p05/press.png | 384x384 RGBA | Charge press |
| refuge_clocher | ignore_v1 | assets/puzzles/p06/clocher.png | 600x600 RGB | Fiche de refuge clocher |
| refuge_halle | ignore_v1 | assets/puzzles/p06/halle.png | 600x600 RGB | Fiche de refuge halle |
| refuge_grenier | ignore_v1 | assets/puzzles/p06/grenier.png | 600x600 RGB | Fiche de refuge grenier |
| paper_report | ignore_v1 | assets/ui/evidence_report.png | 900x1200 RGBA | Support preuve report |
| paper_photo_note | ignore_v1 | assets/ui/evidence_photo_note.png | 900x1200 RGBA | Support preuve photo_note |
| paper_delivery | ignore_v1 | assets/ui/evidence_delivery.png | 900x1200 RGBA | Support preuve delivery |
| paper_cargo_rules | ignore_v1 | assets/ui/evidence_cargo_rules.png | 900x1200 RGBA | Support preuve cargo_rules |
| paper_press_note | ignore_v1 | assets/ui/evidence_press_note.png | 900x1200 RGBA | Support preuve press_note |
| paper_refuges | ignore_v1 | assets/ui/evidence_refuges.png | 900x1200 RGBA | Support preuve refuges |
| paper_statement | ignore_v1 | assets/ui/evidence_statement.png | 900x1200 RGBA | Support preuve statement |
| paper_cartel_final | ignore_v1 | assets/ui/evidence_cartel_final.png | 900x1200 RGBA | Support preuve cartel_final |
| music_atelier | required_v1 | assets/audio/music_atelier.ogg | 100s stereo loop | Musique atelier |
| music_passages | ignore_v1 | assets/audio/music_passages.ogg | 110s stereo loop | Musique passages |
| music_rive_ouverte | required_v1 | assets/audio/music_rive_ouverte.ogg | 85s stereo loop | Musique rive_ouverte |
| amb_rain_inside | required_v1 | assets/audio/amb_rain_inside.ogg | 45s stereo loop | Ambiance rain_inside |
| amb_window | required_v1 | assets/audio/amb_window.ogg | 40s stereo loop | Ambiance window |
| amb_exhibition | required_v1 | assets/audio/amb_exhibition.ogg | 35s stereo loop | Ambiance exhibition |
| sfx_paper_pick | required_v1 | assets/audio/paper_pick.wav | 0.1-2s mono 48 kHz | Effet paper_pick |
| sfx_paper_drop | required_v1 | assets/audio/paper_drop.wav | 0.1-2s mono 48 kHz | Effet paper_drop |
| sfx_flap_a | required_v1 | assets/audio/flap_a.wav | 0.1-2s mono 48 kHz | Effet flap_a |
| sfx_flap_b | ignore_v1 | assets/audio/flap_b.wav | 0.1-2s mono 48 kHz | Effet flap_b |
| sfx_latch | required_v1 | assets/audio/latch.wav | 0.1-2s mono 48 kHz | Effet latch |
| sfx_box_open | required_v1 | assets/audio/box_open.wav | 0.1-2s mono 48 kHz | Effet box_open |
| sfx_calque_rotate | ignore_v1 | assets/audio/calque_rotate.wav | 0.1-2s mono 48 kHz | Effet calque_rotate |
| sfx_photo_slide | ignore_v1 | assets/audio/photo_slide.wav | 0.1-2s mono 48 kHz | Effet photo_slide |
| sfx_crate_a | required_v1 | assets/audio/crate_a.wav | 0.1-2s mono 48 kHz | Effet crate_a |
| sfx_crate_b | ignore_v1 | assets/audio/crate_b.wav | 0.1-2s mono 48 kHz | Effet crate_b |
| sfx_balanced | required_v1 | assets/audio/balanced.wav | 0.1-2s mono 48 kHz | Effet balanced |
| sfx_wood_place | required_v1 | assets/audio/wood_place.wav | 0.1-2s mono 48 kHz | Effet wood_place |
| sfx_water_step | ignore_v1 | assets/audio/water_step.wav | 0.1-2s mono 48 kHz | Effet water_step |
| sfx_contradiction | required_v1 | assets/audio/contradiction.wav | 0.1-2s mono 48 kHz | Effet contradiction |
| sfx_validated | required_v1 | assets/audio/validated.wav | 0.1-2s mono 48 kHz | Effet validated |
| sfx_telephone | required_v1 | assets/audio/telephone.wav | 0.1-2s mono 48 kHz | Effet telephone |
| sfx_last_page | ignore_v1 | assets/audio/last_page.wav | 0.1-2s mono 48 kHz | Effet last_page |

### Éléments UI et fontes

| ID | Scope | Fichier | Dimensions/format | Usage |
|---|---|---|---|---|
| icon_back | required_v1 | assets/ui/back.svg | 96x96 SVG | Commande back |
| icon_menu | required_v1 | assets/ui/menu.svg | 96x96 SVG | Commande menu |
| icon_notebook | required_v1 | assets/ui/notebook.svg | 96x96 SVG | Commande notebook |
| icon_hint | required_v1 | assets/ui/hint.svg | 96x96 SVG | Commande hint |
| icon_rotate_left | required_v1 | assets/ui/rotate_left.svg | 96x96 SVG | Commande rotate_left |
| icon_rotate_right | required_v1 | assets/ui/rotate_right.svg | 96x96 SVG | Commande rotate_right |
| icon_eye | required_v1 | assets/ui/eye.svg | 96x96 SVG | Commande eye |
| icon_zoom | required_v1 | assets/ui/zoom.svg | 96x96 SVG | Commande zoom |
| icon_compare | required_v1 | assets/ui/compare.svg | 96x96 SVG | Commande compare |
| icon_undo | required_v1 | assets/ui/undo.svg | 96x96 SVG | Commande undo |
| icon_reset | required_v1 | assets/ui/reset.svg | 96x96 SVG | Commande reset |
| icon_check | required_v1 | assets/ui/check.svg | 96x96 SVG | Commande check |
| icon_home | required_v1 | assets/ui/home.svg | 96x96 SVG | Commande home |
| icon_sound | required_v1 | assets/ui/sound.svg | 96x96 SVG | Commande sound |
| icon_settings | required_v1 | assets/ui/settings.svg | 96x96 SVG | Commande settings |
| icon_pin | required_v1 | assets/ui/pin.svg | 96x96 SVG | Commande pin |
| ui_paper_panel | required_v1 | assets/ui/paper_panel.svg | 900x1200 SVG; 9slice margins 48 | Support commun pour toutes preuves textuelles |
| ui_button_normal | required_v1 | assets/ui/button_normal.svg | 192x144 SVG; 9slice margins 12 | Composant button_normal |
| ui_button_pressed | required_v1 | assets/ui/button_pressed.svg | 192x144 SVG; 9slice margins 12 | Composant button_pressed |
| ui_focus_ring | required_v1 | assets/ui/focus_ring.svg | 192x144 SVG; 9slice margins 12 | Composant focus_ring |
| ui_selected_outline | required_v1 | assets/ui/selected_outline.svg | 192x144 SVG; 9slice margins 12 | Composant selected_outline |
| font_noto_sans_regular | required_v1 | assets/fonts/noto_sans_regular.ttf | TTF local | Police noto_sans_regular |
| font_noto_sans_semibold | required_v1 | assets/fonts/noto_sans_semibold.ttf | TTF local | Police noto_sans_semibold |
| font_noto_serif_medium | required_v1 | assets/fonts/noto_serif_medium.ttf | TTF local | Police noto_serif_medium |
| game_wordmark | required_v1 | assets/ui/wordmark.svg | 1000x240 SVG | Titre écranaccueil et fin |

### Variantes

| ID | Scope | Fichier | Dimensions/format | Usage |
|---|---|---|---|---|
| variant_atelier_without_floor | required_v1 | assets/architecture/atelier_without_floor.png | 768x768 RGBA | Variation factuelle atelier_without_floor |
| variant_school_stairs_raised | required_v1 | assets/architecture/school_stairs_raised.png | 768x768 RGBA | Variation factuelle school_stairs_raised |
| variant_school_stairs_lowered | required_v1 | assets/architecture/school_stairs_lowered.png | 768x768 RGBA | Variation factuelle school_stairs_lowered |
| variant_awning_intact | required_v1 | assets/architecture/awning_intact.png | 768x768 RGBA | Variation factuelle awning_intact |
| variant_awning_torn | required_v1 | assets/architecture/awning_torn.png | 768x768 RGBA | Variation factuelle awning_torn |
| variant_pane_intact | required_v1 | assets/architecture/pane_intact.png | 768x768 RGBA | Variation factuelle pane_intact |
| variant_pane_broken | required_v1 | assets/architecture/pane_broken.png | 768x768 RGBA | Variation factuelle pane_broken |
| variant_sign_fixed | required_v1 | assets/architecture/sign_fixed.png | 768x768 RGBA | Variation factuelle sign_fixed |
| variant_sign_fallen | required_v1 | assets/architecture/sign_fallen.png | 768x768 RGBA | Variation factuelle sign_fallen |
| variant_chimney_whole | required_v1 | assets/architecture/chimney_whole.png | 768x768 RGBA | Variation factuelle chimney_whole |
| variant_chimney_chipped | required_v1 | assets/architecture/chimney_chipped.png | 768x768 RGBA | Variation factuelle chimney_chipped |
| store_icon_foreground | required_v1 | assets/store/icon_foreground.png | 432x432 PNG | Support commercial icon_foreground |
| store_icon_background | required_v1 | assets/store/icon_background.png | 432x432 PNG | Support commercial icon_background |
| store_icon_monochrome | required_v1 | assets/store/icon_monochrome.png | 432x432 PNG | Support commercial icon_monochrome |

### Éléments mécaniques

| ID | Scope | Fichier | Dimensions/format | Usage |
|---|---|---|---|---|
| p01_l3 | required_v1 | assets/puzzles/p01/l3.png | 360x1080 RGBA | Lé du panorama L3 |
| p01_l1 | required_v1 | assets/puzzles/p01/l1.png | 360x1080 RGBA | Lé du panorama L1 |
| p01_l5 | required_v1 | assets/puzzles/p01/l5.png | 360x1080 RGBA | Lé du panorama L5 |
| p01_l2 | required_v1 | assets/puzzles/p01/l2.png | 360x1080 RGBA | Lé du panorama L2 |
| p01_l4 | required_v1 | assets/puzzles/p01/l4.png | 360x1080 RGBA | Lé du panorama L4 |
| route_face_0 | required_v1 | assets/puzzles/routes/face_0.svg | 512x512 SVG | Volet P03 seulement |
| route_face_1 | required_v1 | assets/puzzles/routes/face_1.svg | 512x512 SVG | Volet P03 seulement |
| route_pattern_dots | required_v1 | assets/puzzles/routes/dots.svg | vector repeat | Tracé de parcours dots |
| route_pattern_dashes | required_v1 | assets/puzzles/routes/dashes.svg | vector repeat | Tracé de parcours dashes |
| route_pattern_double | required_v1 | assets/puzzles/routes/double.svg | vector repeat | Tracé de parcours double |
| mask_0 | required_v1 | assets/puzzles/p04/mask_0.svg | 700x700 SVG | Calque 0 |
| mask_1 | required_v1 | assets/puzzles/p04/mask_1.svg | 700x700 SVG | Calque 1 |
| mask_2 | required_v1 | assets/puzzles/p04/mask_2.svg | 700x700 SVG | Calque 2 |
| mask_target | required_v1 | assets/puzzles/p04/target.svg | 700x700 SVG | Contour témoin |
| action_deliver | required_v1 | assets/puzzles/p07/deliver.svg | 480x320 SVG | Carte opération deliver |
| action_stairs | required_v1 | assets/puzzles/p07/stairs.svg | 480x320 SVG | Carte opération stairs |
| action_floor | required_v1 | assets/puzzles/p07/floor.svg | 480x320 SVG | Carte opération floor |
| action_brace | required_v1 | assets/puzzles/p07/brace.svg | 480x320 SVG | Carte opération brace |
| action_evacuate | required_v1 | assets/puzzles/p07/evacuate.svg | 480x320 SVG | Carte opération evacuate |
| action_release | required_v1 | assets/puzzles/p07/release.svg | 480x320 SVG | Carte opération release |
| action_fasten_floor | ignore_v1 | assets/puzzles/p07/fasten_floor.svg | 480x320 SVG | Carte opération fasten_floor |
| action_load_roof | ignore_v1 | assets/puzzles/p07/load_roof.svg | 480x320 SVG | Carte opération load_roof |
| tide_0 | ignore_v1 | assets/puzzles/p07/tide_0.svg | 720x480 SVG | Coupe niveau 0 |
| tide_1 | ignore_v1 | assets/puzzles/p07/tide_1.svg | 720x480 SVG | Coupe niveau 1 |
| tide_2 | ignore_v1 | assets/puzzles/p07/tide_2.svg | 720x480 SVG | Coupe niveau 2 |
| tide_3 | ignore_v1 | assets/puzzles/p07/tide_3.svg | 720x480 SVG | Coupe niveau 3 |
| tide_4 | ignore_v1 | assets/puzzles/p07/tide_4.svg | 720x480 SVG | Coupe niveau 4 |
| tide_5 | ignore_v1 | assets/puzzles/p07/tide_5.svg | 720x480 SVG | Coupe niveau 5 |
| store_screenshot_panorama | required_v1 | assets/store/screenshot_panorama.png | 1080x1920 PNG | Capture réelle panorama |
| store_screenshot_routes | required_v1 | assets/store/screenshot_routes.png | 1080x1920 PNG | Capture réelle routes |
| store_screenshot_barge | required_v1 | assets/store/screenshot_barge.png | 1080x1920 PNG | Capture réelle barge |
| store_screenshot_plancher | required_v1 | assets/store/screenshot_plancher.png | 1080x1920 PNG | Capture réelle plancher |
| f2_detail | required_v1 | assets/puzzles/p02/f2_detail.png | 1200x900 RGB | Détail tablier plat largeur2 attaches appariées |
| f3_gauge_detail | required_v1 | assets/puzzles/p02/f3_gauge_detail.png | 600x900 RGB | Jauge0–5 eau exactement4 |
| flood_map | required_v1 | assets/puzzles/p06/map.svg | 900x1080 SVG | Nœuds et liaisons exacts ; sauts aux croisements |
| fragment_arcade | required_v1 | assets/puzzles/p06/arcade.svg | 256x256 SVG | Fragment de carte2 travées |
| fragment_ramp | required_v1 | assets/puzzles/p06/ramp.svg | 256x256 SVG | Fragment de carte3 travées |
| tide_cutaway | required_v1 | assets/puzzles/p07/tide_cutaway.svg | 720x480 SVG | Coupe unique ; eau séparée pilotée par état |

Total : 169 entrées, 142 obligatoires (sources comprises), 27 exclues. Aucun de ces assets n’est annoncé produit.

### Tracés de carte sans ambiguïté
Les polylignes `p06.edges[].via` sont obligatoires : K–H contourne la cour par la droite, I–H contourne le plan par le haut. Ne pas remplacer ces arêtes par un segment droit qui traverserait le nœud L sans s’y arrêter. Les traits sont schématiques et ne codent aucune distance. Les extrémités restent exclusivement celles de `ends`.

## Extension 1.2 — Dix plateaux intégrés

Les formes de greybox sont dessinées par `src/ui/expansion_board.gd` ; elles sont déjà présentes et ne sont pas des images finales. Pour le rendu final, chaque plateau reçoit une matière et un entourage 1280² RGBA, source calquée, pivot centre ; aucune règle incrustée dans le raster. Les pièces restent séparées et pilotées depuis JSON. Les bâtiments P08 réutilisent les bâtiments existants ; P10 les charges ; P11 les cordes ; P16 les silhouettes et une variante de navette clairement distincte de la barge. Les textes/chiffres sont rendus par moteur.

P09 : dix pièces et leurs rainures, chemise distincte, ouverture à droite ; tailles rigoureusement conservées. P10 : cinq formes de quatre cases, rotation sans miroir. P11 : deux taquets fixes visuellement rivetés ; intersection de cordes lisible. P12 : silhouettes à capacité proportionnelle, niveaux et quantités visibles. P13 : miroirs / et \, rayon et trois repères sans code couleur exclusif. P14 : montants opaques et départ/arrivée distincts. P15 : charges, sol fragile et portée graduée. P17 : marques numérotées et bande fixe. Aucun shader/ombre ne doit inventer un raccord ou masquer une collision.

Hiérarchie : P09/P10 secondaires soignés ; autres plateaux mécaniques. Pas de nouveau lieu ni asset héros imposé par l'extension. La priorité héros reste la maquette, le plancher et les photographies. Les dix skins sont des livrables finaux futurs, pas une condition pour tester le greybox.

| ID | Scope | Fichier | Dimensions/format | Usage |
|---|---|---|---|---|
| p08_board_skin | required_v1 | assets/puzzles/p08/board_skin.png | 1280x1280 RGBA | Les façades retrouvées |
| p09_board_skin | required_v1 | assets/puzzles/p09/board_skin.png | 1280x1280 RGBA | Le tiroir déformé |
| p10_board_skin | required_v1 | assets/puzzles/p10/board_skin.png | 1280x1280 RGBA | Les caisses au sec |
| p11_board_skin | required_v1 | assets/puzzles/p11/board_skin.png | 1280x1280 RGBA | Les amarres croisées |
| p12_board_skin | required_v1 | assets/puzzles/p12/board_skin.png | 1280x1280 RGBA | L'eau à partager |
| p13_board_skin | required_v1 | assets/puzzles/p13/board_skin.png | 1280x1280 RGBA | La lanterne du quai |
| p14_board_skin | required_v1 | assets/puzzles/p14/board_skin.png | 1280x1280 RGBA | L'escalier articulé |
| p15_board_skin | required_v1 | assets/puzzles/p15/board_skin.png | 1280x1280 RGBA | Les appuis du passage |
| p16_board_skin | required_v1 | assets/puzzles/p16/board_skin.png | 1280x1280 RGBA | La navette des secours |
| p17_board_skin | required_v1 | assets/puzzles/p17/board_skin.png | 1280x1280 RGBA | Les repères de crue |
