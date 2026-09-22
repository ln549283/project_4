# Contrat complet des énigmes

Les valeurs exactes sont dans `design/puzzles.json`. Les états canoniques sont destinés au studio, pas au joueur. Ne jamais imprimer les bits de solution sur les assets. Les gabarits `design/plates/` sont des plans techniques à usage production, non des illustrations de jeu. P00 n'est pas compté dans les sept énigmes.

## Comportements communs

- Entrer affiche l'objectif et le matériel, sans réciter la solution. Les règles locales sont toujours réouvrables via « Fonctionnement ».
- Une manipulation stable est sauvée. Une animation interrompue revient à la pose stable choisie, sans double récompense.
- « Vérifier » produit un diagnostic de règle visible, jamais « mauvaise réponse » sans explication. Aucun essai limité, score ou chronomètre.
- « Annuler » remonte un geste dans l'état local ; « Replacer » demande confirmation et restaure l'état initial de cette énigme seulement. Les indices et preuves vues ne sont pas effacés.
- Le carnet peut afficher une preuve épinglée à côté de la manipulation. Il conserve les observations, pas des solutions automatiquement révélées.
- Pas de validation par délai. Quand l'état satisfait les règles, le bouton « Vérifier »/« Essayer » déclenche la résolution : le joueur reste auteur du constat.
- Les aides H1/H2/H3 sont révélées successivement sur demande. Les rouvrir ne crée pas une quatrième aide. Aucune ne transmet la combinaison complète.

## P00 — ouvrir ce qui reste

**Rôle :** découverte des gestes, 1 min dans les 3 min d'arrivée.

Deux attaches à gauche et droite du coffret. Deux embossages indiquent une flèche vers le haut. Toucher une attache la soulève ; une seconde touche la referme. La languette centrale ne coulisse que si les deux sont ouvertes. La toucher alors déplie le coffret. Alternative : sélection + bouton « Soulever », puis « Ouvrir ». Aucun glissement obligatoire.

Erreur : si attache fermée, elle fléchit légèrement ; label « Une attache retient encore le couvercle. » Aucun bruit de serrure. Récompense : panorama fragmenté, signé Aline.

H1 « Le couvercle est retenu sur les côtés. »
H2 « Les deux attaches peuvent être soulevées séparément. »
H3 « Observe ce qui retient encore le couvercle lorsque tu touches la languette. »

Vérification novice : les deux cibles sont visibles, larges de 56 dp. Un doigt n'a pas à maintenir une attache pendant l'autre ; absence de multitouch obligatoire. Retour accueil puis reprise conserve chaque attache.

## P01 — les rives raccordées

**But joueur :** remettre cinq lés verticaux dans le panorama.
**Accès :** P00. **Durée budgétée :** 4 min (2–6). **Compétence :** observation de continuités.

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
**Accès :** P01. **Durée :** 8 min (5–10). **Compétence :** contraintes partielles et déduction.

### Informations accessibles

Fiche jointe, toujours visible : « Même crue, même heure. Aucune réparation entre ces cinq prises. » Les zones d'un même bâtiment portent des repères architecturaux constants, permettant de comparer sans connaissance du lieu. Les dégâts ne sont pas des états de portes susceptibles de changer dans les deux sens.

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
**Accès :** P02. **Durée :** 9 min (6–12). **Compétence :** visualiser les conséquences couplées d'un changement local.

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
**Accès :** P02, indépendante de P03. **Durée :** 4 min (2–6). **Compétence :** superposition spatiale, observation. Respiration active.

### Géométrie et règles

Trois calques à axes fixes. On peut les tourner chacun par quarts de tour, jamais les déplacer ni les inverser. Une encoche triangulaire en haut de chaque support donne une orientation stable ; ce repère ne marque pas la bonne rotation. Chaque calque peut être masqué temporairement pour l'observer mais doit être présent pour valider. Les zones opaques s'unissent en une ombre noire ; pas d'addition de couleurs ou de règle optique cachée.

Le dessin fonctionnel est un masque logique **7×7**, échelle de production 70 pixels par cellule ; contours légèrement adoucis seulement hors silhouette logique. Le JSON donne chaque masque : trois portiques décalés ; leur union dessine un tablier de sept unités de large et quatre appuis. Tous tournent autour du centre de la cellule (3,3). Cible photographique orientée : ligne supérieure d'eau, ciel et cadre empêchent ambiguïté haut/bas. La cible est affichée en contour à côté puis superposable au toucher.

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
**Accès :** P03 ET P04. **Durée :** 10 min (6–13). **Compétence :** logique de placement, effet du bras de levier, expérimentation informée.

### Matériel complet

Vue de barge frontale, six berceaux numérotés uniquement par position, trois de part et d'autre du pivot. Distances au pivot, dessinées par intervalles égaux : **−3,−2,−1,+1,+2,+3**. Sur chaque caisse une masse relative en gros jetons et en chiffre : lanterne 1, médicaments 2, vivres 3, outils 4, teintures 5, petite presse 6. Toutes les charges sont obligatoires, une par berceau.

Règles inscrites sur le plan de chargement, texte et pictos :

1. « Embarquer les six charges. La barge doit rester horizontale. »
2. « Lanterne et presse dans les deux berceaux centraux : leur gabarit ne passe pas sous les arceaux des autres places. » Les deux objets sont hauts et les quatre emplacements externes disposent d'arceaux bas.
3. « Ne pas placer médicaments et teintures dans deux berceaux voisins. » Huit possibilités de confusion évitées : voisin = deux emplacements consécutifs de la rangée, y compris au centre ; pas une distance en pixels à deviner.

La physique du jeu est le modèle de balance de l'exercice : moment gauche = moment droit. Le pivot visible et l'absence de flottabilité calculée évitent de revendiquer une simulation nautique réaliste. Inclinaison de prévisualisation limitée à ±8 degrés, proportionnelle au déséquilibre ; l'eau décorative ne modifie rien.

### Manipulation et feedback

Sélectionner un objet puis un berceau ; glisser possible. Une place occupée échange les objets ; si un objet vient du plateau, l'occupant retourne à sa place dans le plateau. Les positions interdites par gabarit produisent un aperçu rouge hachuré et le texte « Trop haut pour cet arceau », sans consommer l'objet. Cette règle peut être acceptée en brouillon pour inspection, mais Vérifier la refuse explicitement. Choix de production : placement interdit ne s'applique pas, l'objet reste sélectionné.

Indicateur d'équilibre avec aiguille et marque centrale ; bouton « Comparer les côtés » montre les jetons aux distances réelles (aide visuelle permanente, pas un quatrième indice). Aucun calcul tapé. Vérifier diagnostique dans l'ordre : objets manquants, gabarits, voisinage, déséquilibre. Pas de renversement destructif.

### Toutes les solutions

Gauche à droite, unités :

1. Médicaments, outils, presse, lanterne, teintures, vivres → moments −6−8−6+1+10+9 = 0.
2. Vivres, teintures, lanterne, presse, outils, médicaments → miroir de 1.
3. Outils, médicaments, presse, lanterne, vivres, teintures → −12−4−6+1+6+15 = 0.
4. Teintures, vivres, lanterne, presse, médicaments, outils → miroir de 3.

Exhaustivité : 720 permutations, quatre acceptées. Tous les placements de la lanterne et de la presse se font au centre ; les objets plus lourds éloignés du pivot ont davantage d'effet, observation directe sur l'aiguille. Récompense : N06, étiquette de la presse, grand plan accessible. Aucun chargement historiquement unique n'est affirmé : le joueur retrouve **une organisation possible** compatible avec les marques, pas l'unique photographie de rangement.

H1 « Le poids n'est pas le seul facteur : sa distance au milieu compte aussi. »
H2 « Installe d'abord les deux objets que les arceaux obligent à rester au centre. Observe de quel côté ils font pencher la barge. »
H3 « Si un côté descend trop, rapproche une charge lourde du milieu ou éloigne une charge de l'autre côté. Vérifie ensuite les deux caisses qui ne doivent pas se toucher. »

### Regard novice

La balance réagit pendant l'expérience, mais les objets ne glissent pas. Un joueur sans notion de moment peut comparer les essais. Le dernier indice ne donne aucun ordre de caisses. Charge cognitive bornée par six objets, deux places contraintes. Cas à tester : utilisateur confond équilibre de poids total et bras de levier ; le pivot et l'aiguille doivent permettre de corriger sa compréhension sans tutoriel scolaire.

## P06 — le quartier déplié

**But :** orienter les trois groupes vers leur refuge, en tenant compte de leurs besoins.
**Accès :** P05. **Durée :** 13 min (8–17). **Compétence :** synthèse d'indices de destination, réseau couplé plus grand.

### Première déduction : les refuges

Trois cartes d'origine :
- École : « Le groupe suit le point de rassemblement marqué d'une cloche. »
- Infirmerie : « Les blessés rejoignent l'abri de plain-pied ; aucune marche. »
- Archives : « Les cartons doivent rester au sec au-dessus de la crue. »

Trois refuges présentés simultanément : **Clocher** avec cloche et escalier extérieur ; **Halle** avec entrée large et zéro marche mais sol bas ; **Grenier** au-dessus de la ligne d'eau et accessible par échelle, sans cloche. Les pictos et labels retirent toute dépendance au vocabulaire architectural. Le joueur associe les trois cartes aux refuges : École→Clocher, Infirmerie→Halle, Archives→Grenier. La Halle est un abri valable pour la phase représentée, avant le dernier cran de crue ; ne pas laisser entendre qu'on évacue les blessés vers un lieu déjà submergé.

### Deuxième déduction : carte 3×3

Même règle de volets à deux faces que P03, aucune nouvelle règle cachée. Le plateau agrandi représente un autre plan de l'exercice, **pas** la même carte dont des ports auraient changé de nom. La transition montre le feuillet « Évacuation » se déplier sous le feuillet « Service » conservé.

| Origine | Port | Refuge / port | Longueur |
|---|---|---|---:|
| École | (0,2,N) | Clocher (0,0,W) | 5 cases |
| Infirmerie | (2,1,S) | Halle (1,0,W) | 3 cases |
| Archives | (2,2,S) | Grenier (0,2,E) | 5 cases |

État initial **1,0,1 / 1,0,0 / 1,0,1**. Solution **0,1,1 / 0,1,1 / 0,0,0**. Une solution sur 512, les neuf cases participent à au moins un trajet. Les trois flux sont indépendants sur les courbes mais partagent des volets, d'où contraintes couplées. Les ports inutilisés montrent explicitement une rive sans refuge.

Au-delà du port Clocher, la vue de quartier montre une extension **fixe et interrompue** de trois travées vers Quai haut. Elle n'appartient pas au réseau à résoudre dans P06 ; son objectif est annoncé séparément après la validation (« Il restera à franchir l'interruption »). Pas de faux succès d'une évacuation terminée : le groupe n'a atteint que son rassemblement.

### Validation et pédagogie

Deux éléments nécessaires : associations justes et connexions correspondantes. Si associations fausses, retour sur le besoin contredit : « Ce refuge impose des marches aux blessés » ou « Ce point ne porte pas la cloche du rassemblement » ou « Les cartons restent sous la ligne de crue ». Si réseau faux, feedback de sortie comme P03. Ne pas compter six voies bidirectionnelles comme six groupes.

La solution peut se construire par le trajet court de l'infirmerie puis les trajets longs. La séparation des courbes importe davantage ; l'option tracé individuel et les motifs préviennent la confusion au centre. Réussite N07, dézoom qui révèle les attaches du plancher et l'interruption correspondante.

H1 « Les trois groupes ne cherchent pas le même type d'abri. »
H2 « Associe d'abord chaque besoin à un refuge. Ensuite, suis chaque chemin depuis ses deux extrémités. »
H3 « Quand un passage arrive au bon endroit, garde sa trace affichée. Modifie les autres courbes sans casser cette liaison, et remonte depuis la destination du trajet qui résiste. »

### Regard novice

Le plateau tient dans un carré de 312 dp minimum ; cases d'environ 80 dp après marges, donc pas de précision excessive. Les destinations sont extérieures aux cases ; zoom sur le label disponible. Le jeu ne demande pas de mémoriser P03. La complexité vient de la relation entre parcours, pas d'une nouvelle convention graphique.

## P07 — ce qui portait

**But :** comprendre puis reproduire le transfert du plancher et l'ordre du sauvetage.
**Accès :** P06. **Durée :** 9 min (6–12). **Compétence :** transfert de fonction, causalité et contraintes de temps discrètes. Climax de synthèse ; pas une course.

### P07A — remplacer la fonction

Trois pièces de l'atelier manipulables : porte (1 travée), toiture (2), plancher (3). Le gabarit de l'interruption Clocher→Quai haut mesure **3 travées**, appuis aux deux extrémités ; le plancher a trois panneaux rigidement liés. Les trois pièces portent des prises visibles, aucune action irréversible. Les dimensions se comparent par silhouettes superposables, pas par calcul de perspective. On n'empile pas des morceaux et on ne les scie pas : leurs attaches ont un profil unique qui n'accepte qu'une pièce rigide aux deux extrémités.

La photographie issue de P04 montre quatre appuis et les coutures du plancher ; la sous-face du plancher présente les marques jumelles. La toiture est trop courte, la porte aussi. Seul le **plancher** franchit l'interruption. Essayer une pièce courte montre l'espace restant et dit « L'autre appui reste hors d'atteinte. » La pièce revient si on annule ; la maison n'est pas détruite.

Le joueur installe le plancher dans la **reconstitution** pour comprendre sa fonction. La frise qui suit reconstitue ensuite comment on l'a installé dans la crue : ne pas confondre préparation du modèle et geste chronologique réel.

### P07B — six niveaux, six opérations

Frise à six colonnes **0,1,2,3,4,5**. Ce sont des positions de montée d'eau de la maquette, pas des minutes. Déposer des cartes ne fait pas avancer le temps. « Rejouer » simule les six colonnes, s'arrête à la première contradiction, puis revient au planning intact. Après réussite, reprise des six tableaux N09.

Règles visibles sur une coupe de rive et une fiche, toutes présentes avant premier essai :

- Au niveau **0 seulement**, la rampe de l'atelier permet de décharger les outils ; ensuite son bord est submergé.
- L'escalier vers le clocher doit être relevé **au plus tard au niveau 1** pour que son axe reste accessible. Après, impossible de le régler, mais il reste praticable s'il a été relevé.
- Le plancher ne peut être déposé sur la barge **qu'à partir du niveau 2**, lorsque celle-ci arrive à sa hauteur. Il faut les outils livrés.
- Les étais ne prennent appui **qu'à partir du niveau 3** ; le plancher doit déjà être posé.
- Le groupe doit passer **avant le niveau 5** ; l'escalier relevé et le plancher étayé sont nécessaires.
- On détache la barge **après le passage** ; sinon le plancher perd son support.
- Une opération principale par niveau, convention explicite de la reconstitution : chaque carte représente une phase entière, pas une action instantanée. Le modèle ne permet pas de cumuler deux cartes dans une colonne.

La livraison inclut le déchargement des caisses et la mise de la presse dans le puits central de ballast ; le dessin de cette carte montre ces deux états. Ce détail assure la continuité avec P05, sans demander un second calcul de chargement.

Huit cartes proposées : **Livrer les outils**, **Relever l'escalier**, **Déposer le plancher**, **Étayer le passage**, **Faire passer le groupe**, **Détacher la barge**, **Refixer le plancher de l'atelier**, **Charger la toiture**. Six emplacements. Les deux hypothèses alternatives restent dans un bac « Non retenues » ; leur inadéquation est visuellement testable (plancher indisponible ou toiture trop courte). Le logiciel n'utilise pas une interdiction inexpliquée : elles ne satisfont pas les besoins des six opérations requises.

### Solution et contradiction

0 Livrer → 1 Relever → 2 Déposer → 3 Étayer → 4 Faire passer → 5 Détacher.

Déduction : livraison ne peut se faire qu'à 0 ; escalier au plus tard à 1 donc 1 ; pour évacuer avant 5, il faut avoir étayé, au plus tôt 3, donc étayer à 3 et évacuer à 4 ; plancher avant étais et pas avant 2 donc 2 ; détacher après passage donc 5. Une solution parmi 20 160 séquences de six cartes distinctes choisies parmi huit. L'ordre des actions est cohérent avec les cinq photos mais demande en plus la justification mécanique et le rôle des appuis.

Feedback à la première violation : montrer le niveau et son obstacle (rampe noyée, axe inaccessible, barge trop basse, étais sans appui, escalier absent, ponton instable, support détaché). Texte explicatif de 12 mots maximum, jamais la prochaine bonne carte. Si une étape manque : « Cette reconstitution ne permet pas encore le passage complet. » Possibilité de rouvrir la règle correspondante, pas de solution automatique.

Les indices P07 sont communs aux deux sous-étapes (pas six indices) :

H1 « Compare ce qui manque entre les deux rives avec les pièces de l'atelier, puis avec la photographie. »
H2 « Pour la frise, distingue les gestes qui ont une dernière occasion de ceux qui doivent attendre une certaine hauteur d'eau. »
H3 « Place d'abord les opérations dont la fenêtre est la plus courte. Puis vérifie que chaque support existe avant qu'on l'utilise, et reste en place jusqu'au dernier passage. »

### Regard novice

Le mot « sacrifier » n'apparaît pas avant que le joueur comprenne le rôle du plancher. Un contour comparatif suffit à montrer la bonne longueur sans donner la réponse dans un dialogue. Les règles de marée sont illustrées sur une coupe unique, pas dispersées dans cinq pages. La crue ne progresse jamais pendant que le joueur lit un indice. L'épilogue ne demande pas de deviner une opinion morale.

## Exhaustivité et anti-blocage

Chaque puzzle a ses informations disponibles avant toute action nécessaire. Aucun objet consommé ne doit être redemandé. P03/P04 sont indépendants ; P05 exige les deux preuves. Le carnet conserve cartes et photos après transformation. P07A est réversible tant que la résolution n'est pas confirmée ; en relecture il est toujours réversible.

Les contrôles formels portent sur les règles décrites, pas sur la facilité à percevoir des dessins encore à créer. Toute illustration fonctionnelle doit passer une comparaison avec ces données avant intégration. Ne pas remplacer une forme utile par une approximation générée.
