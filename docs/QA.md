# QA, vérification de conception et critères de livraison

## Statut de cette session

**Effectué :** revue de conception, raisonnement novice écrit pour P00–P07, énumération exhaustive des états combinatoires canoniques, vérification des deux parcours de progression, cohérence documentaire et inventaire. Les huit planches SVG ont été rasterisées et inspectées en planche-contact : aucun débordement ou conflit de label observé à cette revue de gabarits, qui ne remplace pas la QA du jeu final.
**Non effectué :** test humain aveugle, test du jeu exécuté, test sur Android, mesure de performances, audit de publication, validation de dessins et sons finaux inexistants à ce stade.

Commande reproductible : `python3 tools/verify_design.py` depuis la racine, sans dépendance externe. Résultat persistant : `design/verification_report.json`. Les données sont celles que devra consommer le runtime ; une implémentation indépendante devra être confrontée à l'oracle, pas supposée correcte parce que le modèle l'est.

| Contrôle | États inspectés | Résultat attendu |
|---|---:|---|
| P01 permutations de lés | 120 | 1 solution |
| P02 permutations de photos | 120 | 1 solution |
| P03 orientations de 6 volets | 64 | 1 solution, les 6 cases utiles |
| P04 rotations de 3 calques | 64 | 1 solution |
| P05 placements de 6 objets | 720 | 4 solutions, toutes acceptables |
| P06 orientations de 9 volets | 512 | 1 solution, les 9 cases utiles |
| P07 choix/ordre de 6 cartes parmi 8 | 20 160 | 1 solution ; 1 pièce sur 3 a la bonne portée |
| DAG progression | 2 ordres complets | P03/P04 intervertibles, fin accessible |

Total principal : **21 760 configurations** examinées, plus choix de pièce et progression. Cela prouve les propriétés des règles formalisées, pas la beauté du jeu ni sa durée.

## Contrôle des preuves et de l'équité

- P01 : signatures communes partagées entre fichiers sources ; pas de couture artistique supplémentaire imposée par le code.
- P02 : matrice de dégâts respectée dans chaque photo ; éléments non renseignés effectivement hors cadre. Le texte « aucune réparation » apparaît avant la manipulation.
- P03/P06 : ports au centre exact du côté ; tracé et calcul utilisent les mêmes couples ; routes non croisées, destinations réellement atteintes. Ne pas confondre le bit canonique avec l'orientation graphique d'une texture tournée.
- P04 : contour F2/masques correspond au même modèle ; flou esthétique autour autorisé, jamais comme information nécessaire.
- P05 : les quatre solutions fonctionnent ; règle d'arceaux visible ; médicaments/teintures voisins définis de la même manière dans UI et validateur ; poids et distances visibles.
- P06 : indice d'accessibilité de la Halle et sécheresse du Grenier lisible ; absence de promesse que le groupe est déjà au quai.
- P07 : toutes fenêtres et antériorités accessibles avant Essayer ; le « temps » attend indéfiniment le joueur ; projection de gabarits justifie choix du plancher.
- H1/H2/H3 : pas de quatrième aide par dialogue contextuel ; le feedback indique une règle contredite, ne place pas la réponse. Preuves consultables sans dépenser d'aide.
- Narration : pas de preuve cachée uniquement dans un son ou dans un décor non interactif ; témoignage corroboré ; Aline vivante, école évacuée confirmée tôt.

## Matrice de tests du runtime à produire

| ID | Manipulation / condition | Attendu | Sévérité si échec |
|---|---|---|---|
| R01 | Charger chaque état accepté de l'oracle dans le validateur runtime | Tous acceptés | Bloquant |
| R02 | Charger chaque autre état complet des domaines énumérables | Tous refusés selon règles, sans crash | Bloquant |
| R03 | IDs inconnus, doublons, rotations hors plage, photo manquante | Erreur de données contrôlée, pas de succès | Bloquant |
| R04 | Retourner très vite un volet, puis Vérifier | Une action stable par commande ; pas de divergence image/état | Majeur |
| R05 | Réussir P03 avant P04 puis ordre inverse | N05 une seule fois, P05 disponible dans les deux | Bloquant |
| R06 | Ouvrir carnet/loupe/indices au milieu d'une sélection | Sélection et brouillon restaurés | Majeur |
| R07 | Retour Android pendant drag | Objet rendu, aucune perte/duplication | Majeur |
| R08 | Lire trois indices, changer de scène, fermer et reprendre | Trois indices conservés ; aucun quatrième | Majeur |
| R09 | Replacer P03 | Seul brouillon P03 réinitialisé, autres preuves intactes | Majeur |
| R10 | Valider P07, fermer pendant N09 puis pendant l'appel | Reprise au segment stable, fin atteignable | Bloquant |
| R11 | Rejouer P05 depuis l'épilogue, quitter | Sauvegarde campagne complète inchangée | Bloquant |
| R12 | Mauvaise association de refuges + réseau conforme à cette mauvaise association | Refus explicite fondé sur les besoins | Majeur |
| R13 | P05 solutions symétriques et non symétriques | Les quatre déclenchent N06 | Bloquant |
| R14 | P07 cartes alternatives et séquences proches | Contre-exemple compréhensible, planning non effacé | Majeur |
| R15 | Couper musique/effets/vibrations, rejouer tous puzzles | Toutes informations disponibles | Majeur |
| R16 | Horloge système avancée/reculée, mode avion | Aucun impact sur progression | Majeur |

## Sauvegarde et interruptions

Matrice à répéter à minima sur P03 (bits), P05 (objets), P07 (frise), conclusion (scènes) :

1. Fermer normalement, relancer ; état exact.
2. Mise en arrière-plan puis suppression du processus pendant tween ; pose stable et objet unique.
3. Interruption avant écriture temporaire, pendant écriture, après flush, pendant remplacement du slot ancien : au moins dernière génération préservée lisible, jamais chapitre perdu.
4. Tronquer slot récent, altérer son hash, mettre enum invalide : fallback ancien + message de récupération.
5. Invalider les deux copies : conservation des données brutes, écran de diagnostic et nouvelle partie explicitement confirmée ; pas de boucle au boot.
6. Disque plein/IO refusée : dirty state maintenu, pas d'icône mensongère « sauvegardé ».
7. Nouvelle partie annulée puis confirmée : annulation ne modifie rien ; confirmation garde une copie de secours.
8. Version de sauvegarde future : lecture protégée, aucune réécriture ; version migrable : migration testée sur fixtures.
9. Plusieurs actions rapides + passage en pause : file d'écriture sérialisée, générations croissantes, jamais snapshot ancien qui écrase nouveau.

Le hash détecte une corruption accidentelle, pas une fraude ; aucun système antitriche nécessaire. Ne pas promettre récupération après désinstallation : sans cloud le stockage applicatif peut être supprimé.

## QA visuelle et appareils

Évaluer en portrait sur : un téléphone compact 360×640 dp, un appareil long avec encoche et navigation gestuelle, un milieu de gamme 4 Go RAM et une tablette. Android minimum choisi et une version récente disponible. Liste des modèles et OS réellement testés dans `qa/device_results.md` en production ; aucune case présumée passée.

- Capture de chaque écran en texte 100 % et 150 %, avec contraste et mouvement réduit.
- Cibles ≥48 dp, aucun chevauchement, pointages à une main, pas de conflit bord-écran/retour gestuel.
- Lecture des quatre dégâts de P02 par trois personnes sans leur nommer les zones à regarder.
- Suivi de route en niveaux de gris ; trajet long de P06 visible sans confondre les deux courbes d'une case.
- Calques, cargaison, panneau de règle et frise finale lisibles sans rotation de téléphone.
- Pas d'asset placeholder, de numéro auteur, de texte généré illisible ou de fallback Godot icon.
- Pas de clic audio en boucle, saturation ou volume d'erreur agressif.
- Température/batterie : partie de 30 min sur appareil milieu de gamme ; vérifier absence d'animation inutile en pause ou écran éteint.
- Mesurer budgets de TECHNICAL, corriger si dépassés de plus de 20 % ou si l'expérience est affectée.

## Playtest aveugle et durée

Minimum de validation commerciale : **6 joueurs externes** n'ayant pas lu le dossier, dont au moins 3 peu habitués aux jeux d'énigmes et 2 utilisateurs Android sur leur téléphone. Ce n'est pas une étude statistique ; c'est un seuil pratique de détection des problèmes. Le studio prépare build, consignes et formulaire ; ne prétend pas avoir effectué ces séances seul.

Consigne unique : « Restaurez la maquette pour comprendre ce qui s'est passé. Les aides sont dans le bouton Indice. » Pas de coaching spontané. Observateur note localement : heure début/fin par puzzle, blocage d'affordance, fausse hypothèse, aide utilisée, abandon, instant de compréhension du plancher. Aucune télémétrie dans la version vendue ; formulaire de recherche distinct avec consentement si utilisé.

Seuils :
- 6/6 atteignent une fin sans bug bloquant ; au moins 5/6 sans intervention de l'observateur autre que renvoi aux commandes accessibles.
- Médiane première partie 60–90 min ; noter intervalle complet. Temps de pause personnelle exclu. Pas de texte « 90 min » déduit du budget papier.
- Au moins 5/6 peuvent expliquer pourquoi le plancher a été démonté et quels éléments le prouvent.
- Aucun même blocage d'affordance >3 min chez 2 personnes ; corriger l'interface avant la difficulté.
- Au moins 4/6 déclarent avoir eu un moment de déduction satisfaisant sur P03 ou P06, et comprennent leur manipulation plutôt que cliquer au hasard.
- L'aide H3 ne doit pas donner la réponse mot pour mot ; si elle reste inutilisable pour 2 novices, clarifier la méthode et les preuves, pas ajouter H4.

Si jeu trop court : examiner si les validations révèlent involontairement les bons volets ou si les cartes dévoilent l'ordre ; corriger ces fuites et retester. Si la durée naturelle reste inférieure à 60 min, **la cible n'est pas atteinte** : réviser la profondeur de P06 avec preuve de nécessité, nouvelle version du dossier et nouvelles vérifications, sans ajouter d'attente ou de collection. Une conception solide n'interdit pas les ajustements empiriques ; elle évite de les faire au hasard. Si trop long : améliorer la lecture des indices et des chemins, avant d'enlever une contrainte logique.

## Risques classés et réponses

| Risque | Gravité | Détection | Réponse fixée |
|---|---|---|---|
| Durée réelle <60 min | Forte | Playtest chronométré | Recherche de fuites, puis révision ciblée du puzzle principal |
| Cartes perçues comme simple tuyauterie | Forte | Question « qu'avez-vous compris ? » | Art des trajets, besoins des groupes et transformation finale cohérents ; ne pas rajouter cartes similaires |
| Photos incohérentes artistiquement | Bloquante | Matrice visuelle P02 | Composition depuis bâtiment maître, validation avant intégration |
| Balance ressentie comme exercice scolaire | Moyenne | Temps d'hésitation sans expérimentation | Renforcer aiguille/distance visible ; pas d'équation à l'écran |
| P07 répète trop P02 | Moyenne | Retour joueur | Mettre le geste de transformation au centre ; frise courte de synthèse, pas climax de difficulté artificiel |
| Sauvegarde Android corrompue | Bloquante | Injection de pannes | Double génération, fallback, tests réels |
| Art/son insuffisamment cohérents | Forte | Revue de 3 scènes ensemble | Réutiliser masters, supprimer effets disparates |
| Production déborde | Forte | Lots en retard | Réduire décor animé, nombre de variantes SFX et transitions, pas le contenu essentiel |

## Définition « prêt à publier »

Toutes énigmes, histoire et fin intégrées ; zéro placeholder ; 0 bug bloquant/majeur ouvert ; solutions oracle conformes ; sauvegarde et reprise testées ; résultats de durée renseignés ; assets et licences tracés ; version Android signée installable et testée ; icône, captures réelles, descriptif, classification, déclaration de données et informations de support prêts ; exigences officielles du store recontrôlées. Publication et disponibilité du compte sont des étapes de distribution, distinctes de la fin de cette session de conception.
