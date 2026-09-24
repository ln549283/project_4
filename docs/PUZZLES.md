# Contrat 1.2 : 17 énigmes + P00

Les règles P01–P07 ci-dessous restent inchangées. Les ajouts et le rythme sont définis dans [EXPANSION_1_2.md](EXPANSION_1_2.md). Les sections P08–P17 ci-dessous font partie du même contrat.

# Contrat complet des énigmes — conception 1.1 verrouillée

Les valeurs exactes sont dans `design/puzzles.json`. Les états canoniques sont destinés au studio, pas au joueur. Ne jamais imprimer les bits de solution sur les assets. Les gabarits `design/plates/` sont des plans techniques à usage production, non des illustrations de jeu. P00 est une prise en main explicite, sans indices. P01 et P04 sont des respirations actives ; les étapes P02, P03, P05 et P06 portent l'essentiel du raisonnement. P07 est une synthèse jouée. Les durées ci-dessous sont des hypothèses de conception, non des mesures.

## Comportements communs

- Entrer affiche l'objectif et le matériel, sans réciter la solution. Les règles locales sont toujours réouvrables via « Fonctionnement ».
- Une manipulation stable est sauvée. Une animation interrompue revient à la pose stable choisie, sans double récompense.
- « Vérifier » produit un diagnostic de règle visible, jamais « mauvaise réponse » sans explication. Aucun essai limité, score ou chronomètre.
- « Annuler » remonte un geste dans l'état local ; « Replacer » demande confirmation et restaure l'état initial de cette énigme seulement. Les indices et preuves vues ne sont pas effacés.
- Le carnet peut afficher une preuve épinglée à côté de la manipulation. Il conserve les observations, pas des solutions automatiquement révélées.
- Pas de validation par délai. Quand l'état satisfait les règles, le bouton « Vérifier »/« Essayer » déclenche la résolution : le joueur reste auteur du constat.
- Les aides H1/H2/H3 sont révélées successivement sur demande. Les rouvrir ne crée pas une quatrième aide. Aucune ne transmet la combinaison complète.

## P00 — ouvrir ce qui reste

**Rôle :** découverte des gestes, 30–60 s dans l’arrivée.

Deux attaches à gauche et droite du coffret. Deux embossages indiquent une flèche vers le haut. Toucher une attache la soulève ; une seconde touche la referme. La languette centrale ne coulisse que si les deux sont ouvertes. La toucher alors déplie le coffret. Alternative : sélection + bouton « Soulever », puis « Ouvrir ». Aucun glissement obligatoire.

Erreur : si attache fermée, elle fléchit légèrement ; label « Une attache retient encore le couvercle. » Aucun bruit de serrure. Récompense : panorama fragmenté, signé Aline.

La commande « Soulever les deux attaches, puis ouvrir » est montrée directement. Ce tutoriel ne se fait pas passer pour une énigme et ne possède pas de bouton Indice.

Vérification novice : les deux cibles sont visibles, larges de 56 dp. Un doigt n'a pas à maintenir une attache pendant l'autre ; absence de multitouch obligatoire. Retour accueil puis reprise conserve chaque attache.

## P01 — les rives raccordées

**But joueur :** remettre cinq lés verticaux dans le panorama.
**Accès :** P00. **Hypothèse de durée :** 2–4 min. **Compétence :** observation de continuités.

### Matériel et règles

Cadre horizontal à cinq emplacements verticaux dans une vue portrait ; chaque lé s'agrandit à la sélection. Tous les lés possèdent une encoche supérieure empêchant rotation ou retournement. Ils peuvent uniquement changer de place ; déposer sur un emplacement occupé échange les deux pièces. Les marges gauche et droite du cadre sont fixes.

Chaque couture contient **deux** continuations à hauteurs différentes ; jamais seulement une couleur. Données :

| Pièce | Bord gauche | Bord droit |
|---|---|---|
| L3 | Quai bas fixe | Corde haute + roseau bas |
| L1 | Corde haute + roseau bas | Toit haut + rail bas |
| L5 | Toit haut + rail bas | Fenêtre haute + escalier bas |
| L2 | Fenêtre haute + escalier bas | Arbre haut + mur bas |
| L4 | Arbre haut + mur bas | Colline fixe |

Les deux signatures de chaque joint utilisent exactement le même gabarit vectoriel partagé ; les textures ne créent pas de faux raccord. « Haut/bas » désigne deux zones, pas une devinette verbale. Les objets cités sont visuellement représentés, pas écrits sur les lés.

### Solution et feedback

Ordre **L3,L1,L5,L2,L4**. L'ancre gauche fixe L3 ; sa couture impose L1 puis L5 puis L2 puis L4. Les deux ancres permettent aussi de travailler de droite à gauche. 120 permutations, une acceptée. État initial L2,L3,L4,L1,L5.

Sur Vérifier, les coutures incorrectes présentent une petite rupture soulignée ; pas de placement automatique. Message « Certaines lignes s'interrompent aux raccords. » État correct : panorama sans rupture, courte respiration N01, preuves de géographie, pochette de photos accessible.

H1 « Le paysage continue d'un morceau au suivant. »
H2 « Compare deux détails à chaque couture, pas seulement la ligne de la berge. »
H3 « Commence par une extrémité fixe du cadre, puis suis ses deux lignes vers le morceau voisin. »

### Regard novice / risques

Hypothèse naturelle « les bâtiments doivent être triés par taille » contredite par les lignes qui ne se raccordent pas. La vue détaillée conserve simultanément deux bords voisins. Aucun détail utile de moins de 6 dp dans le zoom. État de victoire ne requiert pas d'avoir lu une légende. Ce puzzle enseigne la grammaire de manipulation ; ne pas le vendre comme l'énigme centrale.

## P02 — l'heure sans horloge

**But :** remettre cinq photos dans leur ordre de prise.
**Accès :** P01. **Hypothèse de durée :** 5–9 min. **Compétence :** contraintes partielles et déduction.

### Informations accessibles

Fiche jointe, toujours visible : « Même crue, même montée des eaux. Aucune réparation entre ces cinq prises. » Les zones d'un même bâtiment portent des repères architecturaux constants, permettant de comparer sans connaissance du lieu. Les dégâts ne sont pas des états de portes susceptibles de changer dans les deux sens.

| Photo | Auvent | Vitre | Enseigne | Cheminée |
|---|---|---|---|---|
| F4 | Intact | Intacte | Hors cadre | Hors cadre |
| F1 | Déchiré | Intacte | Fixée | Hors cadre |
| F5 | Hors cadre | Brisée | Fixée | Entière |
| F2 | Hors cadre | Hors cadre | Tombée | Entière |
| F3 | Hors cadre | Hors cadre | Hors cadre | Ébréchée |

Hors cadre signifie réellement masqué/recadré, pas artistiquement dessiné dans un état contradictoire. Les sujets humains des clichés sont décrits dans NARRATIVE ; ils donnent du sens mais ne sont pas nécessaires pour trier. Les numéros F sont internes ; les photos n'affichent ni heure, ni ordre au dos. Plateau initial : F2,F4,F3,F1,F5.

### Interaction et résolution

Cinq emplacements de frise numérotés par position « plus tôt → plus tard ». Toucher deux cartes pour échanger ; glisser possible. Un bouton loupe ouvre le cliché ; comparaison de deux clichés possible, zoom déterministe et déplacement par boutons. Le carnet conserve cette comparaison en sortant.

Chaîne déduite : auvent impose **F4<F1** ; vitre **F1<F5** ; enseigne **F5<F2** ; cheminée **F2<F3**. Une seule permutation sur 120 : **F4,F1,F5,F2,F3**. Aucune estimation de montée des eaux ou connaissance météorologique requise.

Sur Vérifier invalide : « Un élément endommagé réapparaît intact plus tard. » Souligner **la famille de détail** du premier conflit dans l'ordre auvent/vitre/enseigne/cheminée, sans déplacer de carte et sans numéro de case. Ne pas révéler des contradictions inexistantes dans des détails hors cadre. Résolu : les sujets humains sont commentés N02 ; P03 et P04 disponibles.

H1 « Les photographies ne montrent pas toutes les mêmes détails. »
H2 « Un objet cassé ne redevient pas intact pendant cette série. Compare les détails présents sur deux images. »
H3 « Forme d'abord de petites paires “avant / après”, puis relie celles qui partagent une photographie. »

### Regard novice

Le joueur peut arriver à une impasse en observant uniquement l'eau. Les dégâts sont cadrés plus nettement que les vaguelettes décoratives. Le contrat de non-réparation autorise la déduction ; ne pas exiger de supposer que personne n'a réparé. Les cinq images restent consultables après victoire. Aucun texte minuscule au dos.

## P03 — les chemins de service

**But :** retrouver les trois trajets du matériel.
**Accès :** P02. **Hypothèse de durée :** 5–9 min. **Compétence :** visualiser les conséquences couplées d'un changement local.

### Topologie exacte

Six volets dans une grille **2 lignes × 3 colonnes**. Chaque carré possède quatre ports au milieu des côtés N/E/S/W. Un volet retourné modifie simultanément deux chemins courbes non croisés :

- Face 0 : N↔E et S↔W.
- Face 1 : N↔W et S↔E.

Les ports des carrés voisins se raccordent toujours. Une sortie de plateau sans destination dessinée est une extrémité de berge, jamais un téléporteur ou un retour de l'autre côté. La connexion est bidirectionnelle ; pas de priorité temporelle entre flux. Les deux courbes d'une case sont séparées, sans carrefour au centre. La trame doit rendre cette séparation évidente.

Repères studio (r,c,port) :

| Trajet | Origine | Destination | Longueur solution |
|---|---|---|---:|
| Pharmacie → infirmerie | (1,1,S) | (0,1,N) | 4 cases traversées |
| Vivres → réfectoire | (1,2,E) | (0,2,E) | 2 cases |
| Outils → atelier | (1,2,S) | (0,2,N) | 4 cases |

La fiche montre trois associations illustrées. Les étiquettes restent lisibles au toucher des ports. Les six volets sont TOUS nécessaires à la solution. Face initiale **0,1,0 / 1,0,1**.

### Interaction

Toucher une languette retourne le volet, animation 220 ms. Toucher un départ trace son trajet jusqu'à la sortie actuelle ; toucher à nouveau le désélectionne. Le chemin tracé se met à jour si un volet change. Les trois trajets peuvent être épinglés en pointillés, tirets et double ligne ; chaque chemin conserve aussi son nom. Surfaces de sélection du volet séparées des ports extérieurs.

### Solution

**1,1,1 / 0,0,0** en ordre de lecture. Les courbes des trois trajets contraignent ensemble les six volets ; l'énumération de 64 configurations donne une seule solution. Le joueur peut partir d'une arrivée et remonter jusqu'à une origine. Le chemin court des vivres offre un point d'ancrage, mais ses volets influencent les autres liaisons : conserver le succès local en réglant les suivantes.

Validation exige les trois arrivées simultanément, pas juste un chemin quelconque. Feedback en liste de trois lignes : « Pharmacie : arrivée à [nom ou berge] », etc. Les lignes correctes peuvent être cochées ; ne pas verrouiller automatiquement les volets, certains sont partagés. Une boucle fermée interne non utilisée n'est pas un échec supplémentaire : le critère est uniquement les trois trajets. Résolution → evidence_delivery_complete, N03.

H1 « Un volet modifie deux passages en même temps. »
H2 « Pars aussi des destinations : certains trajets ont moins de détours possibles que d'autres. »
H3 « Garde un trajet déjà correct sous les yeux, puis observe quelle autre courbe de ses volets sert aux trajets restants. »

### Regard novice

Tester une languette révèle immédiatement les deux faces et le caractère schématique du modèle. Un exemple non interactif de 2 cases dans la fiche « Fonctionnement » explique seulement un raccord, pas une partie de la solution. Pas de courant d'eau, donc aucun sens implicite de circulation. Les ports ont 48 dp de cible extérieure ; pas besoin de suivre un trait avec le doigt.

## P04 — le contrejour

**But :** reconstruire la silhouette visible sur F2.
**Accès :** P02, indépendante de P03. **Hypothèse de durée :** 1–3 min. **Compétence :** superposition spatiale, observation. Respiration active.

### Géométrie et règles

Trois calques à axes fixes. On peut les tourner chacun par quarts de tour, jamais les déplacer ni les inverser. Une encoche triangulaire en haut de chaque support donne une orientation stable ; ce repère ne marque pas la bonne rotation. Chaque calque peut être masqué temporairement pour l'observer mais doit être présent pour valider. Les zones opaques s'unissent en une ombre noire ; pas d'addition de couleurs ou de règle optique cachée.

Le dessin fonctionnel est un masque logique **7×7**, canvas vectoriel 700×700, 100 unités par cellule ; contours légèrement adoucis seulement hors silhouette logique. Le JSON donne chaque masque : trois portiques décalés ; leur union dessine un tablier de sept unités de large et quatre appuis. Tous tournent autour du centre de la cellule (3,3). Cible photographique orientée : ligne supérieure d'eau, ciel et cadre empêchent ambiguïté haut/bas. La cible est affichée en contour à côté puis superposable au toucher.

Initial **1,2,3** quarts de tour horaires, solution **0,0,0** canonique. Depuis l'initial il faut 3,2,1 touches horaires respectivement, mais aucune interface n'affiche ces nombres comme indice. 64 combinaisons, une seule reproduit la cible.

### Résolution

Le joueur masque deux calques pour voir l'appui que forme le troisième, puis aligne progressivement leurs tabliers. La cible a quatre appuis réguliers, une structure construite et non un éboulement. « Comparer » superpose cible au trait et union opaque ; le surplus est hachuré, le manque reste vide, sans proposer la rotation correcte. Réussite : coïncidence exacte, N04. La comparaison finale montre les mêmes points dans F2.

H1 « Ce qui compte est l'ombre commune, pas l'image de chaque calque isolé. »
H2 « Masque temporairement les autres calques pour comprendre quels appuis appartiennent à chacun. »
H3 « Cherche d'abord à former un tablier continu, puis compare le nombre et la place de ses appuis. »

### Regard novice

Pas de rotation au degré près ; les gestes imprécis enclenchent des quarts de tour. Tous les traits utiles sont agrandissables. Le masque logique doit correspondre exactement aux formes visibles ; pas de validateur fondé sur des alpha flous. Ne pas exiger de connaître le mot « ponton » ; la révélation narrative le nomme après compréhension.

## P05 — la charge utile

**But :** reconstituer une cargaison stable qui respecte ses contraintes de transport.
**Accès :** P03 ET P04. **Hypothèse de durée :** 6–10 min. **Compétence :** logique de placement, effet du bras de levier, expérimentation informée.

### Matériel complet

Vue de barge frontale, six berceaux numérotés uniquement par position, trois de part et d'autre du pivot. Distances au pivot : intervalles unitaires de chaque côté, intervalle DOUBLE entre les deux berceaux centraux : **−3,−2,−1,+1,+2,+3**. Sur chaque caisse une masse relative en gros jetons et en chiffre : lanterne 1, médicaments 2, vivres 3, outils 4, teintures 5, petite presse 6. Toutes les charges sont obligatoires, une par berceau.

Règles inscrites sur le plan de chargement, texte et pictos :

1. « Embarquer les six charges. La barge doit rester horizontale. »
2. « Lanterne et presse dans les deux berceaux centraux : leur gabarit ne passe pas sous les arceaux des autres places. » Les deux objets sont hauts et les quatre emplacements externes disposent d'arceaux bas.
La règle de voisinage médicaments/teintures de la conception 1.0 est supprimée : elle ne retirait aucune des quatre solutions déjà imposées par les deux règles précédentes. Ne pas l’afficher ni l’implémenter.

La physique du jeu est le modèle de balance de l'exercice : moment gauche = moment droit. Le pivot visible et l'absence de flottabilité calculée évitent de revendiquer une simulation nautique réaliste. Inclinaison de prévisualisation limitée à ±8 degrés, proportionnelle au déséquilibre ; l'eau décorative ne modifie rien.

### Manipulation et feedback

Sélectionner un objet puis un berceau ; glisser possible. Une place occupée échange les objets ; si un objet vient du plateau, l'occupant retourne à sa place dans le plateau. Les positions interdites par gabarit produisent un aperçu rouge hachuré et le texte « Trop haut pour cet arceau », sans consommer l'objet. Une pose interdite ne s'applique pas et l'objet reste sélectionné. Lors d'un échange, vérifier le gabarit des **deux** objets avant toute mutation. Si l'un des deux ne rentre pas, refuser l'échange entier. Un objet peut toujours retourner dans le plateau, par sélection puis toucher son emplacement fantôme : aucun arrangement partiel ne peut emprisonner un objet.

Indicateur d'équilibre avec aiguille et marque centrale ; bouton « Comparer les côtés » montre les jetons aux distances réelles (aide visuelle permanente, pas un quatrième indice). Aucun calcul tapé. Vérifier diagnostique dans l'ordre : objets manquants, gabarits, déséquilibre. Pas de renversement destructif.

### Toutes les solutions

Gauche à droite, unités :

1. Médicaments, outils, presse, lanterne, teintures, vivres → moments −6−8−6+1+10+9 = 0.
2. Vivres, teintures, lanterne, presse, outils, médicaments → miroir de 1.
3. Outils, médicaments, presse, lanterne, vivres, teintures → −12−4−6+1+6+15 = 0.
4. Teintures, vivres, lanterne, presse, médicaments, outils → miroir de 3.

Exhaustivité : 720 permutations, quatre acceptées. Tous les placements de la lanterne et de la presse se font au centre ; les objets plus lourds éloignés du pivot ont davantage d'effet, observation directe sur l'aiguille. Récompense : N06, étiquette de la presse, grand plan accessible. Aucun chargement historiquement unique n'est affirmé : le joueur retrouve **une organisation possible** compatible avec les marques, pas l'unique photographie de rangement.

H1 « Le poids n'est pas le seul facteur : sa distance au milieu compte aussi. »
H2 « Installe d'abord les deux objets que les arceaux obligent à rester au centre. Observe de quel côté ils font pencher la barge. »
H3 « Si un côté descend trop, rapproche une charge lourde du milieu ou éloigne une charge de l'autre côté. Change une paire à la fois pour comprendre son effet. »

### Regard novice

La balance réagit pendant l'expérience, mais les objets ne glissent pas. Un joueur sans notion de moment peut comparer les essais. Le dernier indice ne donne aucun ordre de caisses. Charge cognitive bornée par six objets, deux places contraintes. Cas à tester : utilisateur confond équilibre de poids total et bras de levier ; le pivot et l'aiguille doivent permettre de corriger sa compréhension sans tutoriel scolaire.

## P06 — le quartier sous l’eau

**Remplace intégralement l’ancienne grille de neuf volets.** Aucun second puzzle de tuyaux en V1.
**But :** reconstituer deux liaisons manquantes du plan et proposer trois parcours compatibles avec la crue.
**Accès :** P05. **Hypothèse de durée :** 10–16 min, à vérifier. **Raisonnement :** croisement de preuves, élimination d’accès, partage d’un passage, contre-exemple.

### Toutes les informations disponibles avant manipulation

1. Le cliché F3, déjà présent depuis P02, montre une échelle de crue ; l’eau atteint exactement le repère **4**. Une loupe présente cet extrait sans souligner le bon chiffre. L’échelle va de 0 à 5, sens vertical évident.
2. Le plan montre la hauteur de fermeture de chaque liaison ; « inaccessible lorsque l’eau atteint sa marque ». Les hauteurs sont également dessinées en coupe, donc aucune connaissance de topographie n’est requise.
3. Le relevé de secours indique : École → Clocher ; Infirmerie → Halle haute ; Archives → Grenier. Le groupe au brancard **ne peut pas prendre de marches** ; les deux autres groupes le peuvent. Tous les refuges et les nœuds restent au sec jusqu’au repère 5 inclus.
4. Le plan comporte quatre blancs, mais seulement deux fragments conservés : un morceau représentant une arcade de deux travées et un représentant une rampe de trois. La légende précise : « Deux liaisons bâties ; les autres blancs sont des bras d’eau. Les trajets peuvent partager un passage. »

Les fragments sont des **morceaux de carte** figurant des ouvrages fixes en maçonnerie. Ce ne sont pas deux planches transportables. Ils ne peuvent donc pas remplacer le plancher dans P07. Le plan est explicitement schématique et non à l’échelle. Chaque emplacement porte deux ou trois coutures-repères pour le fragment correspondant ; la longueur d’un trait à l’écran n’est jamais une mesure.

### Graphe exact et visible

S = École ; I = Infirmerie ; A = Archives ; J = Place ; K = Terrasse ; L = Cour haute ; C = Clocher ; H = Halle haute ; G = Grenier. Les coordonnées de composition sont dans le JSON. Une intersection de traits sans nœud **ne permet pas** de changer de chemin ; dessiner un saut de ligne à tout croisement accidentel.

| Liaison fixe | Ferme à l’eau | Marches | Lecture |
|---|---:|---|---|
| S–J | 6 | Non | Accès de l’école à la place |
| I–J | 6 | Non | Accès large de l’infirmerie |
| A–J | 6 | Oui | Escalier des archives |
| K–C | 6 | Oui | Montée vers le clocher |
| L–H | 6 | Non | Rampe vers la halle haute |
| L–G | 6 | Oui | Montée vers le grenier |
| K–H | 6 | Oui | Raccourci par des marches |
| I–H | 4 | Non | Raccourci bas noyé à la hauteur observée |

| Blanc | Fragment compatible | Liaison restaurée |
|---|---|---|
| J–K | Arcade, 2 travées | Large, sans marche, fermeture à 6 |
| S–C | Arcade, 2 travées | Même type de liaison |
| K–L | Rampe, 3 travées | Large, sans marche, fermeture à 6 |
| A–G | Rampe, 3 travées | Même type de liaison |

Une arcade et une rampe seulement. Un fragment ne peut être dupliqué. Retirer ou déplacer un fragment est toujours possible avant validation ; cela invalide les parcours qui en dépendent, sans les effacer. Une route peut passer par l’origine d’un autre groupe. Aucun nombre de groupes maximum par liaison, aucun ordre de passage caché, aucun itinéraire le plus court imposé.

### Interaction

Choisir un cran d’eau 0–5 pour prévisualiser les accès submergés. Poser les deux fragments par toucher → emplacement. Sélectionner un groupe puis toucher les nœuds successifs de son parcours ; le prochain nœud doit être adjacent. Toucher un nœud déjà dans ce parcours tronque la suite, ce qui sert d’annulation locale. Les routes sont donc simples, sans boucle ; aucun mouvement fin le long d’un trait n’est requis. Trois motifs de tracé comme P03 ; les nœuds portent leurs noms et un détail agrandi.

On peut voir les trois parcours ensemble ou isolément. « Essayer » demande simultanément : hauteur conforme à F3, deux fragments correctement logés, trois itinéraires complets, secs et compatibles avec le brancard. Tester une hauteur fausse est autorisé en brouillon et ne détruit rien.

### Déduction novice et solutions admises

À la hauteur 4, I–H est noyé. Le brancard doit quitter I vers J. Il ne peut emprunter J–A (marches), donc a besoin de l’arcade **J–K**. De K, il ne peut aller directement à H (marches), ni traverser le clocher ; il lui faut la rampe **K–L**, puis L–H. Les deux fragments sont maintenant placés par une nécessité, pas par une couleur ou un code. Les autres groupes peuvent partager ces passages.

- École : **S–J–K–C**.
- Infirmerie : **I–J–K–L–H**.
- Archives : **A–J–K–L–G** **ou** **A–J–K–H–L–G**. Les deux sont valides ; le second emprunte des marches, permises à ce groupe.

Ne pas comparer seulement au premier exemple. Il y a une configuration valide de hauteur/fragments et deux triplets de parcours simples. Le vérificateur recherche les chemins, il ne suppose pas que les exemples sont exhaustifs.

Contre-exemples indispensables : arcade S–C et rampe A–G sauvent deux trajets courts mais isolent le brancard ; garder I–H ne marche qu’à une hauteur fausse ; utiliser K–H pour le brancard ignore les marches. Chacun est réfutable par une preuve visible.

Feedback dans cet ordre : hauteur incompatible avec F3 ; fragment manquant/incompatible ; origine ou destination absente ; liaison inexistante ; liaison noyée ; marches interdites. Montrer le segment observé et la règle, **jamais un autre itinéraire prêt à recopier**. Les trois routes correctes ne sont pas verrouillées avant le succès global.

H1 « Commence par retrouver la hauteur de l'eau sur la dernière photographie. Tous les traits du plan ne seront plus des passages. »
H2 « Le groupe avec le brancard ne peut pas emprunter les marches. Cherche son trajet avant de placer les deux fragments. »
H3 « Un passage restauré peut servir à plusieurs groupes. Compare le coût des raccourcis isolés avec un détour partagé, puis vérifie chaque trajet en entier. »

### Sortie et continuité

P06 prouve qu’un trajet compatible conduit le groupe de l’école **au clocher**, pas déjà au quai haut. L’extension C→Quai haut est un raccord séparé visible en bord de maquette, absent du graphe de P06, et explicitement annoncé comme la dernière interruption à expliquer. Sa largeur est de trois travées. Ne jamais faire marcher les silhouettes jusqu’au quai avant P07. La Halle haute est au sec pendant **toute** la séquence, sans second sauvetage hors champ.

## P07 — ce qui portait

**But :** comprendre puis reproduire le transfert du plancher et l'ordre du sauvetage.
**Accès :** P06. **Hypothèse de durée :** 5–7 min. **Compétence :** transfert de fonction, causalité et contraintes de temps discrètes. Climax de synthèse ; pas une course.

### P07A — remplacer la fonction

Trois pièces de l'atelier manipulables : porte, toiture et plancher, **tous de portée 3 travées**. Le gabarit de l'interruption Clocher→Quai haut mesure **3 travées**, appuis aux deux extrémités ; le plancher a trois panneaux rigidement liés. Les trois pièces portent des prises visibles, aucune action irréversible. Les dimensions se comparent par silhouettes superposables, pas par calcul de perspective. On n'empile pas des morceaux et on ne les scie pas : leurs attaches ont un profil unique qui n'accepte qu'une pièce rigide aux deux extrémités.

Le détail F2 disponible depuis P02, repris après P04, montre un tablier **plat**, **deux unités de large**, avec des **attaches appariées**. La coupe de l’interruption montre une portée de trois. Les trois candidats font la même longueur : la porte n’a qu’une unité de largeur et des gonds simples ; la toiture a un profil rigide en V et pas d’attaches appariées ; le plancher est plat, deux unités de large et possède les bonnes attaches. Chaque face se consulte avec « Retourner la pièce », sans donner son nom dans le commentaire de Nelle. Le but est de retrouver l’élément photographié, pas de prétendre qu’aucune autre construction ne serait imaginable.

Seul le **plancher** satisfait les quatre observations. Les critères sont dans `p07.requirements`. Diagnostic d’un essai : « Le profil ne correspond pas à la photo », « Le passage est trop étroit » ou « Les attaches ne correspondent pas ». Une pièce revient au support si l’essai échoue. La maison n’est pas détruite. La phrase de Nelle qui nommait le plancher avant le choix a été supprimée.

Le joueur installe le plancher dans la **reconstitution** pour comprendre sa fonction. La frise qui suit reconstitue ensuite comment on l'a installé dans la crue : ne pas confondre préparation du modèle et geste chronologique réel.

### P07B — six phases observées, six opérations

Frise à six colonnes **0,1,2,3,4,5**. Ce sont six phases documentées de la reconstitution, associées aux repères de crue 0–5 ; pas six tours de jeu ni six durées égales. Déposer des cartes ne fait pas avancer le temps. « Rejouer » simule les six colonnes, s'arrête à la première contradiction, puis revient au planning intact. Après réussite, reprise des six tableaux N09.

Règles visibles sur une coupe de rive et une fiche, toutes présentes avant premier essai :

- Au niveau **0 seulement**, la rampe de l'atelier permet de décharger les outils ; ensuite son bord est submergé.
- L'escalier vers le clocher doit être relevé **au plus tard au niveau 1** pour que son axe reste accessible. Après, impossible de le régler, mais il reste praticable s'il a été relevé.
- Le plancher ne peut être déposé sur la barge **qu'à partir du niveau 2**, lorsque celle-ci arrive à sa hauteur. Il faut les outils livrés.
- Les étais ne prennent appui **qu'à partir du niveau 3** ; le plancher doit déjà être posé.
- Le groupe doit passer **avant le niveau 5** ; l'escalier relevé et le plancher étayé sont nécessaires.
- On détache la barge **après le passage** ; sinon le plancher perd son support.
- Le carnet conserve six phases avec un geste principal chacune. Une carte décrit le geste observé dans une phase ; il s’agit de classer les faits documentés, pas d’affirmer qu’une seule action réelle était physiquement possible à chaque hauteur.

La livraison inclut le déchargement des caisses et la mise de la presse dans le puits central de ballast ; le dessin de cette carte montre ces deux états. Ce détail assure la continuité avec P05, sans demander un second calcul de chargement.

Six cartes proposées : **Livrer les outils**, **Relever l’escalier**, **Déposer le plancher**, **Étayer le passage**, **Faire passer le groupe**, **Détacher la barge**. Les deux faux choix trop évidents de la version 1.0 sont supprimés, ainsi que leur bac. Les six gestes sont documentés dans le carnet de chantier accessible dès l’entrée de P07. Le joueur ne doit pas deviner une action absente de la liste.

### Solution et contradiction

0 Livrer → 1 Relever → 2 Déposer → 3 Étayer → 4 Faire passer → 5 Détacher.

Déduction : livraison ne peut se faire qu'à 0 ; escalier au plus tard à 1 donc 1 ; pour évacuer avant 5, il faut avoir étayé, au plus tôt 3, donc étayer à 3 et évacuer à 4 ; plancher avant étais et pas avant 2 donc 2 ; détacher après passage donc 5. Une solution parmi les **720 permutations de six cartes**. Ce nombre ne mesure pas la difficulté ; les fenêtres réduisent fortement l’espace utile. L'ordre des actions est cohérent avec les cinq photos mais demande en plus la justification mécanique et le rôle des appuis.

Feedback à la première violation : montrer le niveau et son obstacle (rampe noyée, axe inaccessible, barge trop basse, étais sans appui, escalier absent, ponton instable, support détaché). Texte explicatif de 12 mots maximum, jamais la prochaine bonne carte. Si une étape manque : « Cette reconstitution ne permet pas encore le passage complet. » Possibilité de rouvrir la règle correspondante, pas de solution automatique.

Les indices P07 sont communs aux deux sous-étapes (pas six indices) :

H1 « La longueur seule ne suffit pas. Compare aussi la largeur, le profil et les attaches visibles sur la photographie. »
H2 « Pour la frise, distingue les gestes qui ont une dernière occasion de ceux qui doivent attendre une certaine hauteur d'eau. »
H3 « Place d'abord les opérations dont la fenêtre est la plus courte. Puis vérifie que chaque support existe avant qu'on l'utilise, et reste en place jusqu'au dernier passage. »

### Regard novice

Le mot « sacrifier » n'apparaît pas avant que le joueur comprenne le rôle du plancher. Un contour comparatif suffit à montrer la bonne longueur sans donner la réponse dans un dialogue. Les repères de crue sont illustrées sur une coupe unique, pas dispersées dans cinq pages. La crue ne progresse jamais pendant que le joueur lit un indice. L'épilogue ne demande pas de deviner une opinion morale.

## Exhaustivité et anti-blocage

Chaque puzzle a ses informations disponibles avant toute action nécessaire. Aucun objet consommé ne doit être redemandé. P03/P04 sont indépendants ; P05 exige les deux preuves. Le carnet conserve cartes et photos après transformation. P07A est réversible tant que la résolution n'est pas confirmée ; après résolution, il reste inspectable dans son état final. La relecture indépendante par chapitre est hors V1 ; une nouvelle partie reste disponible.

Les contrôles formels portent sur les règles décrites, pas sur la facilité à percevoir des dessins encore à créer. Toute illustration fonctionnelle doit passer une comparaison avec ces données avant intégration. Ne pas remplacer une forme utile par une approximation générée.

### Tracés de carte sans ambiguïté
Les polylignes `p06.edges[].via` sont obligatoires : K–H contourne la cour par la droite, I–H contourne le plan par le haut. Ne pas remplacer ces arêtes par un segment droit qui traverserait le nœud L sans s’y arrêter. Les traits sont schématiques et ne codent aucune distance. Les extrémités restent exclusivement celles de `ends`.


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
