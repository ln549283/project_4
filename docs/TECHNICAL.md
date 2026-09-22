# Architecture technique et contrat de production

## Décision et sources vérifiées le 22 septembre 2026

Moteur **Godot 4.6.2 Standard**, GDScript typé, 2D, renderer Compatibility, cible Android native. Pas de C#, plugin payant, navigateur embarqué, serveur, Firebase ou connexion réseau. La disponibilité de cette version et le flux d'export ont été vérifiés dans les sources officielles ci-dessous ; les cibles réglementaires du store seront recontrôlées au moment du release.

- Version choisie : https://godotengine.org/download/archive/4.6.2-stable/
- Export Android : https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html
- Principes de sauvegarde : https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html

La documentation Android citée décrit OpenJDK 17, SDK/NDK, templates d'export et signature des bundles. Produire un AAB release signé pour diffusion ; APK debug pour essais locaux. Le tutoriel de sauvegarde illustre le stockage local mais **ne garantit pas à lui seul** le protocole robuste à deux générations défini ci-dessous : c'est un travail applicatif à implémenter et tester.

## Périmètre système

- Android minimum produit : Android 10/API 29, arm64-v8a ; cible d'API de publication fixée au lot release après lecture de la politique officielle alors applicable. Ce choix de minimum est un choix produit, pas une obligation du moteur.
- Version moteur et export templates identiques, inscrites dans `toolchain.lock` dès installation ; pas de changement automatique en cours de production.
- Rendu à 60 fps pendant manipulation ; limite 30 fps lorsque scène statique après 2 s, réveil immédiat à l'interaction. Ne pas recharger toutes les textures à chaque clic.
- Aucune permission dangereuse. Sauvegarde dans stockage interne application ; pas d'accès contacts, photos, microphone, GPS ou stockage partagé par défaut.
- Son et contenu inclus dans le bundle ; aucune génération IA à l'exécution. Pas de dépendance à une connexion pour la première partie.
- Package choisi : `com.nibylogames.foldedshores`, version commerciale initiale 1.0.0, versionCode 1 au premier release. Vérifier l'absence de collision dans le compte avant premier upload. Ne jamais réutiliser l'ID d'un autre jeu.

## Arborescence à produire

```
project.godot
export_presets.cfg                 # sans identifiants de signature
src/core/{game_state,progression,save_service,scene_router,audio_service}.gd
src/puzzles/{p01,p02,p03,p04,p05,p06,p07}_controller.gd
src/rules/{panorama,chronology,routes,masks,cargo,sequence}_rules.gd
src/ui/{paper_flap,evidence_card,drag_drop,focus_manager,hint_panel}.gd
scenes/{boot,home,workbench,archive,window,ending}.tscn
scenes/puzzles/p01.tscn ... p07.tscn
scenes/ui/{pause,settings,notebook,confirm,save_error}.tscn
content/puzzles.json               # copie générée depuis design, pas éditée séparément
content/dialogue_fr.json
content/evidence_fr.json
content/hints_fr.json              # copie de design/hints_fr.json
content/localization.csv
assets/{backgrounds,architecture,props,puzzles,ui,audio,fonts}/
tests/{rules,state,save,ui}/
build/                            # ignoré par Git
```

Le dépôt de conception contient `design/`, pas encore cette structure runtime. Ne pas annoncer ces composants comme implémentés. Les JSON sont importés/chargés avec inclusion explicite dans l'export et validés au boot en développement ; un JSON absent est un échec de build, pas une récupération silencieuse avec données vides.

## Modules et responsabilités

**GameState**, autoload : état sérialisable unique, mutation via commandes (`flip_tile`, `swap_photo`, `place_cargo`, `set_hint_level`, `solve_puzzle`). Aucun Node, Texture ou Callable sérialisé. Le rendu observe l'état ; aucune condition de victoire déduite d'une position animée en pixels.

**Progression** : DAG de `design/puzzles.json`, `can_enter(id)` et `apply_solved(id)`. Événements idempotents. `solved` monotone en mode campagne. Retourner un état de puzzle résolu n'est possible qu'en relecture sandbox. La jonction P03/P04 déclenche N05 une fois, quel que soit l'ordre.

**PuzzleController** : convertit gestes/focus en commandes, enregistre historique local borné à 100 actions stables, appelle validateur pur sur Vérifier. Émet résultat `{valid, violations:[{rule_id, evidence_id, params}], resolved_state}`. Ne contient pas les textes de diagnostic ; ceux-ci sont indexés par clé.

**Rule engines** :
- Panorama : unicité de pièce, bords, ancres.
- Chronologie : séquence de dégâts monotones sur observations réellement présentes.
- Routes : suivre le couple de ports, voisins, détection de boucle par `(r,c,entry)` ; ne pas confondre sortie et case. Comparer destinations réelles à destinations attendues.
- Masks : rotation entière des bitmaps, union booléenne ; pas de comparaison de captures raster.
- Cargo : entiers, unicité/complétude, gabarits, voisinage, somme des moments nulle. Pas de flottants de moteur physique.
- Sequence : pièce aux attaches compatibles, six cartes distinctes correctes, fenêtres et antériorités ; diagnostic chronologique première violation. Une « mauvaise » hypothèse est expliquée par la fonction qu'elle ne remplit pas.

**SceneRouter** : pile de routes `{view_id, parent, subview, focus_id}` ; les overlays ne détruisent pas le puzzle. Seuls IDs stables persistés, jamais chemins arbitraires provenant d'une sauvegarde.

**AudioService** : bus Master/Music/SFX/Ambience, fondus 300 ms, priorité du feedback tactile sur ambiance sans répétition agressive. Mute effet immédiat, application en pause suspendue.

**Animation** : tween purement visuel entre deux états validés ; l'événement de jeu est enregistré **avant** le tween. En fermeture pendant animation, l'état final stable se réaffiche. Les dialogues conservent un index de segment et peuvent être relus ; ne jamais répéter une récompense.

## Schéma de sauvegarde v1

```json
{
  "schema_version": 1,
  "content_version": "1.0",
  "generation": 42,
  "campaign_id": "local-random-id",
  "saved_at_utc": "ISO8601-for-diagnostics-only",
  "completed": false,
  "solved": ["p00", "p01"],
  "seen_evidence": ["evidence_report", "evidence_map"],
  "seen_scenes": ["n00", "n01"],
  "hints": {"p01": 0, "p02": 1},
  "location": {"view": "s06", "subview": "photos", "focus": "photo_f4"},
  "puzzles": {
    "p00": {"latches": [true, true], "opened": true},
    "p01": {"order": ["L3", "L1", "L5", "L2", "L4"]},
    "p02": {"order": ["F2", "F4", "F3", "F1", "F5"]},
    "p03": {"bits": [0,1,0,1,0,1]},
    "p04": {"turns": [1,2,3]},
    "p05": {"slots": [null,null,null,null,null,null]},
    "p06": {"assignments": {}, "bits": [1,0,1,1,0,0,1,0,1]},
    "p07": {"donor": null, "slots": [null,null,null,null,null,null]}
  },
  "narrative": {"active_scene": null, "segment": 0},
  "settings": {"text_scale": 1.0, "music": 0.7, "sfx": 0.8, "vibration": true, "reduced_motion": false, "high_contrast": false, "locale": "fr"}
}
```

Le document ci-dessus est illustratif d'une partie après P01 ; la génération n'a aucun rôle ludique. Horloge système utilisée seulement pour diagnostic, jamais portes ou récompenses. Les traces sélectionnées, zoom et sélection sont des préférences de vue facultatives persistées dans `view_state` séparé ; ne pas considérer leur absence comme corruption de campagne. Les objets non présents dans slots P05/P07 sont dérivés du stock total ; ne pas sauvegarder deux inventaires contradictoires.

### Protocole résistant aux interruptions

Deux slots `user://campaign_a.json` / `campaign_b.json`. Chaque slot est une enveloppe `{generation,payload_utf8,sha256}` où `payload_utf8` est **la chaîne JSON exacte** dont les octets UTF-8 sont hashés. Ne pas réencoder un dictionnaire et comparer une empreinte dépendante de l'ordre des clés.

1. Au chargement, lire les deux slots indépendamment, vérifier parsing/enveloppe, hash, schéma, enums, tailles, plages et invariants de progression. Choisir la plus grande génération valide. Si un fichier invalide existe, conserver une copie diagnostique avant toute réécriture et informer si une récupération est nécessaire.
2. Pour sauver, sérialiser un snapshot stable, génération valide+1 ; écrire dans le slot **le plus ancien/invalide**, jamais dans le seul slot valide le plus récent. Écriture dans `.tmp` du slot concerné, flush et fermer ; relire, vérifier le hash et le schéma ; remplacer uniquement le slot choisi. Conserver l'autre génération intacte. Ne pas supposer que le renommage garantit la persistance après coupure électrique ; les deux fichiers couvrent les écritures interrompues ordinaires, à tester sur appareils.
3. Une écriture échouée ne marque pas le snapshot « sauvegardé ». Garder dirty state en mémoire, notifier et proposer de réessayer. Pas de boucle infinie d'IO.
4. Au lancement sans fichiers : nouvelle partie. Si deux fichiers existent mais sont invalides : aucun effacement silencieux ; écran de récupération, copie brute de diagnostic dans stockage app, nouvelle partie confirmée. Export diagnostic via feuille de partage native seulement si implémenté et demandé ; sinon conserver les copies et proposer assistance, sans fausse promesse d'export disponible.
5. Nouvelle partie confirmée : garder le dernier snapshot valide dans `campaign_restart_backup.json`, puis créer les slots de la nouvelle campagne. Une seule sauvegarde de reprise, pas un cloud.
6. Réglages changés en accueil sans campagne : `settings.json` distinct avec écriture temporaire et fallback. Lorsqu'une campagne existe, préférer ces réglages globaux à la copie de diagnostic du snapshot.
7. Migrateur versionné explicite ; version inconnue plus récente → « Partie issue d'une version plus récente » et aucune écriture destructive. Une modification du puzzle invalide un brouillon incompatible mais conserve résolutions, preuves et fin ; la migration doit être documentée et testée.

Sauver après chaque manipulation terminée (pas chaque pixel de drag), indice, segment narratif validé et changement de vue. Queue sérialisée, coalescence maximale 150 ms pour actions rapides, flush lors de pause/application background. Le dernier geste peut être perdu en arrêt brutal avant écriture ; aucune promesse d'absence absolue de perte. Objectif : au plus un geste, jamais un chapitre.

## Budgets techniques

Objectifs sur un Android milieu de gamme 4 Go RAM : démarrage à froid <5 s, changement de vue déjà visitée <400 ms, input→feedback <100 ms, 60 fps manipulation p95 frame <20 ms, pas de frame >100 ms liée au chargement récurrent. Mémoire totale cible <250 Mo. Taille installée cible <180 Mo, téléchargement AAB appareil cible <100 Mo. Mesures requises, pas des valeurs atteintes.

Textures : maximum 2048² par atlas utile, fonds 1080×1920 si nécessaire ; garder scène courante et preuves récentes, décharger les grandes photographies inutilisées. Peu de transparences plein écran. Masques de puzzle géométriques, textures décoratives séparées. SVG sources versionnés, exports PNG/WebP selon compatibilité d'import ; vérifier l'alpha et le rendu final en Android. Aucun shader 3D requis.

## Builds, tests et release

En production : validation JSON et `python3 tools/verify_design.py`, tests GDScript headless pour validateurs, boot headless, puis APK debug installé sur un vrai appareil. Un export réussi ne vaut pas test tactile. AAB signé seulement au lot release ; clés hors Git et sauvegardées par le producteur selon son dispositif existant. Le studio termine tous les éléments accessibles avant de signaler un éventuel accès manquant.

Ne pas installer un SDK ou moteur par une commande distante non inspectée. Sources officielles, version explicite et checksum lorsque disponible. Conserver licences Godot et fontes. Vérifier API cible, exigences de test du compte, déclarations de données, classification et assets store aux sources officielles Google au moment de publication ; le dossier n'invente pas leurs valeurs futures.
