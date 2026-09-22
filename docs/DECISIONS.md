# Décisions et critique de conception

## Exploration faite avant sélection

| Piste | Atout | Faiblesse décisive | Verdict |
|---|---|---|---|
| Observatoire dont les ombres réécrivent une constellation | Images spectaculaires | Codes optiques arbitraires, risque de connaissances externes et de puzzles répétitifs | Écartée |
| Atelier de restauration d'une ville en livre animé | Manipulation tactile, transformation physique signifiante, production 2D bornée | Peut devenir un simple puzzle de tuyaux habillé | Retenue avec pluralité des raisonnements et conséquence narrative du démontage |
| Service des objets perdus d'une gare inondée | Histoires humaines, objets variés | Dialogue et appariement d'étiquettes dominants, peu d'espace manipulable | Écartée |
| Théâtre mécanique à spectacles imbriqués | Belle scénographie | Multiplication des décors, symboles de théâtre arbitraires, sens narratif faible | Écartée |

Aucune de ces évaluations ne prétend établir une absence de concurrent sur le marché. L'originalité recherchée est la combinaison précise de l'objet transformable, de la reconstitution et du geste final, pas l'invention de chaque mécanisme abstrait.

## Décisions verrouillées

- D01 : carton tactile 2D, Android portrait, offline, achat 3,49 €.
- D02 : pas d'horreur, Aline vivante, récit complet, pas de méchant caricatural.
- D03 : sept puzzles, deux branches intermédiaires, trois lieux. La quantité ne remplace pas la densité.
- D04 : les cartes de routes sont explicitement schématiques. Pas de promesse de géométrie réaliste contredite par les règles.
- D05 : deux états par volet ; pas de rotation arbitraire ni de simulation physique du papier.
- D06 : P05 accepte quatre solutions. Une unique composition artistique ne doit jamais restreindre le validateur.
- D07 : finale sur une frise discrète, sans rapidité demandée ; elle conclut les déductions précédentes.
- D08 : aucune aide n'est payante ; troisième indice méthodologique, aucune autosolution.
- D09 : moteur Godot 4.6.2 avec export natif. Pas de serveur, analytics ou génération à l'exécution.
- D10 : français seulement annoncé en v1 ; textes externalisés dès le premier commit de production.
- D11 : le rapport est préliminaire et incomplet, pas délibérément mensonger. Aline avait témoigné ; une annexe avait été classée séparément.
- D12 : la preuve finale est une convergence : ordre des clichés, silhouette du ponton, traces et dimensions du plancher, annexe signée. Le succès d'un puzzle seul n'établit jamais l'histoire.

## Autocritique et modifications déjà intégrées

1. **Deux cartes trop proches.** Le premier essai 2×2 avait des chemins trop courts et plusieurs orientations gagnantes involontaires. Remplacé par P03 à six volets, trois flux ; P06 étend le modèle et demande une nouvelle lecture des destinations. Les scripts exploratoires ne font pas partie du contrat.
2. **P04 n'a pas huit minutes de contenu.** Reclassé comme respiration active de quatre minutes, sans revendiquer une difficulté artificielle. Les calques proposent une expérience visuelle différente.
3. **La maquette semblait magique.** Suppression des tiroirs qui s'ouvrent parce qu'un validateur sait qu'une réponse est correcte. Les feuillets se révèlent par déploiement de l'objet ; le feedback de validation est celui du jeu et de Nelle, pas d'une machine omnisciente.
4. **Sacrifier un atelier pouvait devenir un chantage émotionnel.** Aucun choix moral à l'aveugle ; le joueur rassemble des preuves de la nécessité du geste avant de le reproduire, et peut annuler la manipulation.
5. **Le témoignage risquait de rendre le jeu superflu.** L'annexe décrit la décision sans donner les positions du modèle. Sa signification concrète ne se comprend qu'après les manipulations. Elle est conservée dans l'enveloppe de la maquette déployée, sans code artificiel.
6. **La balance pouvait devenir une épreuve de calcul.** Balance animée, masses en jetons, distances marquées, comparaison visuelle du bras de levier ; équation réservée aux développeurs. Pas besoin d'additionner mentalement.
7. **Durée et qualité premium invérifiables sur papier.** Objectifs explicitement hypothétiques ; critères de playtest, couverture de sauvegarde et budgets d'assets fixés. Ne pas afficher « 90 minutes » sur le store avant mesure.
8. **Le jeu pouvait demander de retenir cinq images.** Carnet épinglé, inspection agrandie de deux preuves, et comparaison sans fermer le puzzle.

## Quand modifier sans demander au producteur

Le studio peut corriger un libellé, agrandir une cible, clarifier un contraste, ajuster une transition ou rendre une preuve plus visible sans rouvrir le concept. Toute modification des données change la version du design et exige une nouvelle énumération. Conserver les IDs pour migrer les sauvegardes.

Si les tests donnent une médiane inférieure à 60 min, ne pas ajouter d'attente ni de texte de remplissage : examiner les fuites de solution, puis réviser la profondeur de P06 seulement si les mesures le justifient, et retester ; ce changement reste une révision de conception explicitement documentée. Si les novices dépassent 100 min, d'abord clarifier les affordances et la consultation des indices. Pas de nouveau chapitre.

Aucune décision de conception n'est volontairement reportée. Les seules inconnues restantes sont empiriques (temps, ergonomie, appareils, disponibilité du titre) ou de distribution (clés et compte du producteur).
