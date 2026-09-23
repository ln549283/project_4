# Simulation novice intégrale — conception 1.1

Simulation critique sur documents et données, pas un test humain. Le joueur supposé ne connaît aucune combinaison, lit les labels usuels et n'a besoin d'aucune connaissance technique. Les identifiants/solutions ici sont réservés au studio.

| Moment | Ce que je sais / vois avant d'agir | Hypothèse plausible, manipulation et retour | Résultat / objectif suivant |
|---|---|---|---|
| Accueil | Continuer si partie existante, sinon Nouvelle partie | Je commence ; réglages accessibles sanspartie | N00 explique exposition et mère participante |
| P00 | Deuxattaches et languette visibles, instruction de toucher | Je tire trop tôt : les attaches encorefermées sont signalées, aucun échec destructif | Attaches ouvertes puis coffret ; panorama proposé |
| P01 | Cinqbandes, hautfixe, deuxtracés parcouture et ancres | Je raccorde une ligne mais pas l'autre : comparaison de couture montre la rupture ; loupe permanente | L3L1L5L2L4 ; géographie comprise ; tous les clichés, note et témoignage acquis même si N01interrompu |
| Respiration | Survie connue, témoignage indique quai/clocher sans pièce | Je peux le lire sans résoudre la suite par simpleappel | Objectif ordonnerphotos |
| P02 | Cinq images et note : même crue, aucune réparation ; étatsvisibles exactsmatrice | Je prends hors cadre pour intact : détail et note distinguent inconnud'intact ; je compare deuximages | Auvent situeF4avantF1 ; vitre F1avantF5 ; enseigne F5avantF2 ; cheminée F2avantF3. Les critères donnent l'ordre sans datecachée |
| Branche | Deuxfeuillets explicitement ouverts | Je choisis librement calques ou livraisons ; sortir conserve brouillon | Aucun matériel d'une branche requis par l'autre |
| P03 | Fiche explicite trois couples ; volet 2 courbes, toucher pour retourner | Je ferme un parcours et casse un autre ; tracéisolé montre son aboutissement et je reviens au voletpartagé | Troisroutes simultanées, faces111000 ; preuve persistante ; objectif autrebranche si nécessaire |
| P04 | Troiscalques et contourissuF2, hautvisible | Je tourne uncalque mais nevois pas lequel dépasse ; masquerautres/comparercible permetisoler | Rotations000 ; structure4appuis ; respiration courte assumée |
| Jonction | Les deux preuves sont connues, scèneN05 une fois | Je quitte juste après résolution : pending reprend N05, P05déjà déverrouillé | Chargement proposé sans recliquer une anciennepreuve |
| P05 | Sixmasses et distances dessinées, deux objets hauts/places centrales | J'égalise les masses totales : aiguille encore penchée ; déplacer une charge montre l'effetdistance. Échange interdit refuse les2déplacements ; retour plateau restepossible | Une des4organisations acceptées ; pas d'ordre historique prétenduunique ; plan et consignes des groupes acquis |
| P06 observation | F3depuis P02 ; jauge4inspectable ; légende des liaisons/seuils/marches ; trois destinations | Je suppose eau0 car brouillon initial : Essayer renvoieàF3, pas au chiffre4. Je règle d'aprèsphoto | I–H noyé, autresliaisons sèches ; tous refuges secs |
| P06 déduction | Deuxfragments decarte2/3 travées, chacun2logements compatibles ; trajets partageables | Je répare S–C et A–G : deux trajets courts mais brancard isolé. Je suis sesmarches interdites, retire les fragments, lesmets J–K/K–L | Brancard IJKLH oblige les2passages ; école SJKC ; archives AJKLG ou AJKHLG ; lesdeuxadmis |
| P06 sortie | Clocheratteint, extension distincte jusqu'auquai visible | Je voudrais réemployer lesfragments : légende/maçonnerie expliquent que ce sont des portions deplan, pas pièces physiques | Objectif comparer3piècesatelier |
| P07A | Tousspan3, F2plat/largeur2/attaches, inspection recto verso | Porte assez longue mais étroite/gonds ; toiturerigide enV. Détailphotographique suffit pour réfuter ceschoix | Plancher satisfaitles4critères. Transfert annulable, dialogue après choix seulement |
| P07B | Coupeunique et6fenêtres, outils déchargés/presseballast représentés | Je veux évacuer avant d'étayer : simulation montre support absent puis rend planning intact. La crueattend ma commande | Livrer0/relever1/plancher2/étais3/passage4/largage5 déduits par fenêtres et dépendances |
| Conclusion | Photos, témoignage et modèle déjà réunis | Ajouterpreuves par toucheronglet puiscartel (drag facultatif), pas de choixmoral ni indicecaché | Cartelcorrigé, appel, exposition, générique ; completed aprèsN11 |
| Après fin | Explorer / générique / accueil | Je consulte les preuves/étatsvalidés sans lesdéfaire ; Nouvelle partie demande confirmation et conservebackup | Aucun replayisolé ni nouveau chapitre |

## Simulation de l'autre ordre

P02→P04 : projection/F2 déjà acquis ; N04 ne mentionne aucune livraison accomplie. P03 ensuite utilise uniquement evidence_delivery déjà acquis. AprèsP03, N03 puis N05, une fois. P02→P03→P04 fonctionne symétriquement. Le vérificateur parcourt ces deux ordres et vérifie chaque required_by_stage contre les acquisitions effectives.

## Disponibilité, erreurs et anti-softlock

`design/evidence.json` est la matrice exhaustive acquisition→usage ; les acquisitions suivent solved, jamais seen. Rapportinitial accessible avant P00 ; panorama après P00 ; photos/note/témoignage après P01 ; livraison/projection après P02 ; cargaison/presse aprèsjonction ; refuges après P05 ; coupeaprès P06 ; cartelfinal après P07. Aucun indice progressif ne contient un renseignement indispensable absent des preuves.

Fermer dans un zoom : revenir au contexte. Fermer entre validation et dialogue : état final + preuve + pending déjàsauvés ensemble ; reprendre le premier segment non acquitté. BrouillonP06dont le fragment est déplacé : routes conservées mais invalides visibles, modifiables. ObjetP05malplacé : retirerplateau, jamaisconsommé. P07 simulation échouée : intact ; retirer le plancher avant validation restaure l'atelier. Aucun paramètre audio/texte n'influe sur réponse. Zéro limite d'essais ou d'indicesouverts déjàacquis.

## Ce que cette simulation ne démontre pas

Elle montre une chaîne logique sans information tardive connue. Elle ne démontre pas que le joueur remarque un dommage peint, trouve P06 plaisant, comprend le brasdelevier ou joue60 minutes. T12 puis T18 doivent mesurer cespoints avec personnes novices ; jusqu'alors qualification exacte : conception auditée, non playtestée.
