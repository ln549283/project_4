# Vertical slice — La lanterne du quai

## Périmètre
Une seule séquence P13. La version autonome s'ouvre depuis « La lanterne · séquence premium » à l'accueil et possède une sauvegarde séparée. En campagne, la même réalisation remplace seulement la présentation de P13 ; contrat, prérequis et solution inchangés. Aucun autre puzzle ne reçoit d'art final.

## Direction
Atelier nocturne au bord de l'eau, bleu pétrole, lumière miel, cuivre/laiton patiné. La maquette papier de la bible est réinterprétée ici par un environnement illustré plus réaliste, avec papier au premier plan. Ce mélange est une hypothèse de DA à évaluer, pas une validation automatique de la bible entière. Priorités : profondeur du paysage, matériaux crédibles, instruments tactiles, peu d'interface.

## Séquence
Introduction courte, démarrage explicite pour l'audio web, apparition du plateau (650 ms), toucher pour tourner (200 ms), maintien 500 ms pour examiner un objet, rayon continu (650 ms). Réussite après stabilisation du dernier geste ; illumination de la ville, accord musical, conclusion narrative. Annuler reste possible pendant le calcul d'une réussite. Aucun chrono ni pénalité. Carnet avec les trois indices originaux.

Le bouton Calme/Mouvement applique le mouvement réduit : pas de parallaxe/reflets animés, transitions de 80 ms. Toutes les cibles des miroirs font 148 unités dans le repère 1080, soit plus de 48 dp à 360 de largeur. Le plateau est contenu dans l'écran portrait, sans scroll. Adaptation centrée et proportions conservées pour les autres formats.

## Assets livrés
`assets/slice/lantern/` :
- `atelier.webp` : illustration de fond 1024×1536, compression de l'image originale générée ; eau et lueur animées dans le shader, sans déformation de toute l'image.
- `mirror.webp` : instrument isolé avec alpha, 512×512 ; six instances réutilisées, inspection agrandie.
- `title.ttf` : DejaVu Serif, licence incluse dans FONT_LICENSE.txt.
- `river_theme.ogg` : composition originale déterministe de 64 secondes, notes espacées, résonances douces. Source reproductible `tools/slice/generate_audio.py`.
- `river_air.ogg` : texture stéréo filtrée en boucle de 64 secondes, évoquant eau et souffle ; synthèse originale, aucune banque externe.
- `mirror_0/1/2.wav`, `touch.wav`, `mark.wav`, `arrival.wav` : bruitages et ponctuations originaux. Boucles OGG stéréo 24 kHz, effets WAV mono 16 bits/24 kHz. Ce choix ciblé remplace pour cette séquence les formats de mastering génériques de la bible.
- Plateau, gravures, rayon, halos, repères et UI : dessin vectoriel natif, indépendants de la logique de résolution.

## Provenance des illustrations
Outil intégré imagegen, génération originale. Prompt atelier : « Production background illustration for a premium portrait mobile narrative puzzle game. Handcrafted miniature conservator's desk by a tall window overlooking a French riverside town at blue hour. Layered paper, wood and aged brass, warm lantern at left, central lower work surface empty for an interactive board; no text, no UI. Sophisticated cinematic warm/cool lighting. »
Prompt miroir : « Single top-down isolated antique optical mirror on a circular aged brass rotating foot. Horizontal narrow bevelled silver-blue glass blade. Engraved concentric circles, four screws, warm upper-left highlights, cool teal shadows, transparent RGBA, no lettering. »
Prompts complets conservés dans `tools/slice/image_prompts.md`. Les images exportées sont des optimisations de format, sans retouche créative automatique.

## Validation requise
- Tests automatisés : mêmes règles P13 ; gestes réels via boutons, annulation, inspection, indices, mute, succès, sauvegarde indépendante, reprise et protection contre une réussite périmée.
- Captures : véritable moteur Godot Compatibility, rendu OpenGL logiciel sur GitHub Actions, introduction / jeu / inspection / carnet / arrivée / conclusion.
- Revue visuelle avant publication : lisibilité du rayon et des objets à 540×960, absence de débordement, cohérence matériaux/UI, finale lisible.
- Restent à mesurer sur téléphones physiques : toucher long, qualité haut-parleur/casque, chauffe/mémoire et fluidité. Une capture et des tests headless ne certifient ni 60 fps mobile ni le succès commercial.

**Statut initial : en revue.** Ne pas lancer le reste de la production artistique sur cette seule implémentation.
