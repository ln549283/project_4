> **Version active : 1.2.** Les paragraphes 1.1 ci-dessous décrivent la base conservée ; l’extension en fin de document et [EXPANSION_1_2.md](EXPANSION_1_2.md) définissent les ajouts et prennent priorité sur les anciens nombres et prérequis.

# Son et animation — conception 1.1

Direction artistique, formats et inventaire exhaustif : [../ASSET_BIBLE.md](../ASSET_BIBLE.md). Ce document définit uniquement le comportement animé et sonore ; aucune seconde liste de production.

## Animation

| Événement | Durée | Construction |
|---|---:|---|
| Coffret | 600 ms | Base/couvercle/attaches séparés ; pivots bible |
| VoletP03 | 220 ms | ÉchelleX vers0, changementface, retour ; état logique préenregistré |
| Prendre papier | 120 ms | Translation4 px et ombre ; aucune oscillation permanente |
| Balance | 300 ms | angle clamp(moment×0,35,−8,+8), tween visuel ; aucune physique |
| Eauambiante | 8s boucle | Deuxbandes décoratives très légères ; aucune information exclusive |
| Transfertplancher | 600 ms | Retrait/pose simple ; annulation avant validation |
| Six phases finales | 18s max | Six poses ; avance manuelle, aucune attente obligatoire |
| Exposition | 8s | Silhouettes sur positionsclés |
| Contradiction | 250 ms | Trait/hachure/label, aucun flash |

Mouvementréduit : posesstables et fondu80 ms maximum. Les transitions standard180–350 ms ne bloquent pas durablement commandes/retour. Save avant tween ; reprise affiche étatstable. Pas de lip-sync, éclairagedynamique, simulationtissu ou nouvelasset pour chaque animation.

## Musique, ambiances, effets

Deux compositions originales : music_atelier100s enboucle (piano feutré et souffleharmonique,68 bpm indicatifs, faible densité) de l'ouverture à P07 ; music_rive_ouverte85s (motifinitial plus lumineux, finpropre) à la validationP07 et générique. Fonducroisé1,2s. Pas de troisième morceau.

Ambiances : amb_rain_inside45s, amb_window40s, amb_exhibition35s ; boucles sans voixcompréhensible. MastersWAV48kHz24 bit, exportsOGGstéréo. SFXmonoWAV48kHz16 bit,0,1–2s ; aucun pic >−3dBFS ; musique cible−23 LUFS intégrés à contrôler réellement, pas une certification.

Événement→fichier : prise papier/papier calque/détail photo→paper_pick ; posephoto/page→paper_drop ; volet→flap_a ; attache→latch ; coffret→box_open ; caisse→crate_a ; équilibre→balanced ; plancher→wood_place ; contradiction→contradiction ; réussite→validated ; appel→telephone. Eau defrise sans SFXspécifique. Pas de variantesfichiers non requises par CSV.

Bus Master/Music/SFX/Ambience, musique et effets réglables séparément ; le réglage effets inclut ambiance. Sauver mute immédiatement ; pauseapp suspend, reprise sans empilement. Vérifier casque et haut-parleurphone. Aucun indice exclusivement audible. Vibrationoptionnelle10–20 ms surpose, absente par défaut si indisponible ; pas de permission superflue.

## Supports commerciaux

Icône : maisonpapier/plancherpasserelle sur eau graphite, lisible48 px sans texte. Featuregraphique1024×500 depuis artfinal, titre àgauche, marge48 px ; captures réelles panorama/routes/barge/plancher. Description : « Dépliez une ville de papier et reconstituez un sauvetage. Observez, reliez et transformez les pièces d'une maquette dans une aventure d'énigmes sans publicité, jouable hors ligne. » Ne promettre durée/langues qu'après validation.


## Extension 1.2 — Gestes et rythme

Les dix ajouts réutilisent les matières papier/bois/eau, sans nouvelle scène géographique ni troisième musique imposée. Prévoir glissement sec pour P09, pose étouffée P10/P15, frottement de corde P11, versement P12 et passage doux P16, sans information exclusivement sonore. Réutiliser les SFX existants tant que la production sonore finale n'a pas commencé ; ne pas déclarer ces bruitages finalisés. Aucune transition ne retarde l'entrée joueur. Une réussite courte ferme chaque exercice ; les pauses plus longues restent aux changements d'acte.
