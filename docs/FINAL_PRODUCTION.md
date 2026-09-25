# Production finale — suivi vérifiable

## Autorisation et référence

Le producteur a validé le vertical slice, puis demandé la production finale dans Godot, au même niveau visuel et sonore, avec des commits réguliers. Cette autorisation remplace la suspension artistique historique de T12. Elle ne vaut pas mesure de durée, test de performance mobile ou validation des stores.

Référence immuable : P13 du commit ee5699e. Campagne : P00 puis 17 énigmes, ordre et règles de la conception 1.2. Aucune énigme supplémentaire ajoutée.

## État de reprise

- Terminé avant cette production : règles, campagne, sauvegardes, 51 indices, P13 artistique intégré et validé.
- Partiel : présentation des menus et des autres énigmes, encore fondée sur la greybox.
- À réaliser : matières et assets propres aux autres séquences, manipulations animées, transitions, orchestration sonore, présentation narrative et finale ; contrôle visuel du parcours complet.
- À mesurer sur appareils réels : performance, audio, interruptions Android/iOS, confort tactile, durée novice. Ne pas confondre rendu automatisé et validation physique.

## Lots

| Lot | Contenu | État |
|---|---|---|
| F01 | Palette, typographie, boutons, décors communs, son persistant, réglages audio | Premier commit dc8d00a ; tests Godot et 23 captures CI passés ; revue visuelle confirme que les plateaux demandent encore leur production propre |
| F02 | Coffret, panorama, façades, archives et photographies | Panorama et façades revus par captures ; coffret animé, atlas de détails photographiques et agrandissement intégrés dans ea65a07, QA en cours |
| F03 | Volets, masques, colis et cargaison | Objets et matières intégrés ; cargaison refaite pour supprimer le débordement horizontal ; QA en cours |
| F04 | Cordages, eau, crue, carte et traversée | Accessoires intégrés, tiroir et traversée animés ; parcours carte rapproché du haut de l’écran ; QA en cours |
| F05 | Passerelle, étais, synthèse et conclusion | Habillage de synthèse intégré ; carnet, dialogue et conclusion en finition |
| F06 | Revue intégrale, formats portrait, sauvegardes, exports mobiles | À réaliser |

## Asset ajouté F01

`assets/production/archive.webp` : fond d'archives de la même salle municipale. Génération intégrée imagegen avec `atelier.webp` comme référence stylistique, puis conversion WebP qualité 88 sans retouche de contenu. Pas de repères logiques peints dans le décor. Prompt exact dans `tools/production/image_prompts.md`.

Les textures, la police et les sons P13 sont réutilisés depuis leur dossier versionné, sans duplication. Le mix de campagne reste indépendant de celui de P13 pour éviter la superposition des musiques.

## Intégration F02 en cours

- `assets/production/buildings.webp` : six miniatures cohérentes, atlas transparent 1536×1024. Alpha vérifié ; régions de 512×512 définies dans le moteur. École, atelier, halle, grenier, clocher, infirmerie.
- `assets/production/panorama.webp` : panorama continu, cinq découpes moteur selon les identités des lés. Le solveur et les raccords contractuels restent inchangés.
- Accueil composé autour du paysage ; accès outils regroupés pour ne plus empiler sept gros boutons sous chaque plateau.
- Déplacements des façades, niveaux des récipients et repères de crue interpolés avec respect du mouvement réduit.
- Correction de progression P01 → P08 : l'ancien contrôleur visait encore P02, désormais verrouillé à cette étape. Test Godot dédié ajouté.

## Reprise du 25 septembre 2026

Dernier lot validé avant reprise : 52d44fb, CI et rendus réussis. Les changements suivants étaient présents mais non commités ; ils ont été conservés et repris, pas recréés. Le commit ea65a07 les regroupe pour la vérification Godot et visuelle.

Assets ajoutés : coffret.webp (base sans langues d’attaches), coffret_latches.webp (source des pièces animées), props.webp (12 accessoires), photo_details.webp (8 détails intacts/endommagés). Prompts, mode de génération et dimensions réelles documentés dans tools/production/image_prompts.md. La mise en page de P05 a été reconstruite après observation du débordement réel, et la double gestion touch/mouse des anciens plateaux supprimée puisque l’émulation tactile est activée dans le projet.

Le carnet utilise désormais des titres français ; les scènes narratives reprennent Jo et Aline en silhouettes de papier et atténuent la musique. La conclusion réutilise le panorama restauré. Aucun résultat de QA physique ou d’écoute sur téléphone n’est revendiqué.
