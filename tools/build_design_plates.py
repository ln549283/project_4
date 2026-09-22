#!/usr/bin/env python3
"""Generate exact engineering SVGs, never production illustrations."""
import json
from pathlib import Path
from html import escape
ROOT=Path(__file__).resolve().parents[1]
D=json.loads((ROOT/'design/puzzles.json').read_text())
OUT=ROOT/'design/plates';OUT.mkdir(exist_ok=True)
BG='#f1e8d5';INK='#26333c';ACC='#476d73'
def begin(title,w=1200,h=960):
 return [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">',f'<rect width="{w}" height="{h}" fill="{BG}"/>',txt(40,50,title,28),txt(40,82,'GABARIT STUDIO — données exactes / solution dévoilée / illustration finale à produire',16)]
def txt(x,y,s,size=18,anchor='start',fill=INK):return f'<text x="{x}" y="{y}" font-family="sans-serif" font-size="{size}" text-anchor="{anchor}" fill="{fill}">{escape(str(s))}</text>'
def line(x1,y1,x2,y2,color=INK,width=3):return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="{width}"/>'
def rect(x,y,w,h,fill='none',stroke=INK):return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{stroke}" stroke-width="2"/>'
def save(name,s): (OUT/name).write_text('\n'.join(s+['</svg>'])+'\n')
def gridmask(s,m,x,y,cell=28):
 for r,row in enumerate(m):
  for c,v in enumerate(row):s.append(rect(x+c*cell,y+r*cell,cell,cell,INK if v=='1' else '#fffaf0','#c4b9a4'))
def routes(name):
 p=D[name];s=begin(name.upper()+' — topologie de la solution')
 cell=180;x0=250;y0=210
 for r in range(p['rows']):
  for c in range(p['cols']):
   x=x0+c*cell;y=y0+r*cell;b=p['solution'][r*p['cols']+c]
   s.append(rect(x,y,cell,cell,'#fffaf0'))
   ports={'N':(x+90,y),'E':(x+180,y+90),'S':(x+90,y+180),'W':(x,y+90)}
   for a,z in D['route_tile_pairs'][str(b)]:
    ax,ay=ports[a];zx,zy=ports[z]
    # The quadratic control point is the shared corner, preserving non-crossing arcs.
    cx=x+(180 if 'E' in (a,z) else 0);cy=y+(0 if 'N' in (a,z) else 180)
    s.append(f'<path d="M {ax} {ay} Q {cx} {cy} {zx} {zy}" fill="none" stroke="{ACC}" stroke-width="12"/>')
   s.append(txt(x+90,y+97,f'{r},{c} : face {b}',14,'middle'))
 for route in p['routes']:
  for key,label in [('start',route['start_label']),('end',route['end_label'])]:
   r,c,side=route[key];x=x0+c*cell;y=y0+r*cell
   px,py={'N':(x+90,y),'E':(x+180,y+90),'S':(x+90,y+180),'W':(x,y+90)}[side]
   dx,dy={'N':(0,-50),'E':(45,0),'S':(0,45),'W':(-45,0)}[side]
   s.append(line(px,py,px+dx,py+dy,'#a86546',5))
   anchor={'N':'middle','S':'middle','E':'start','W':'end'}[side]
   s.append(txt(px+dx,py+dy-5,label,18,anchor))
 y=820
 for i,route in enumerate(p['routes']):s.append(txt(40,y+i*30,route['start_label']+' → '+route['end_label'],20))
 save(name+'_solution.svg',s)
for name in ['p03','p06']:routes(name)
s=begin('P01 — signatures de raccord')
for i,k in enumerate(D['p01']['solution']):
 x=60+i*220;s.append(rect(x,180,210,420,'#fffaf0'));s.append(txt(x+105,220,k,26,'middle'))
 left,right=D['p01']['pieces'][k]
 for y,v in [(290,left),(400,right)]:
  words=v.split('_')
  for j in range(0,len(words),2):s.append(txt(x+10,y+(j//2)*24,' '.join(words[j:j+2]),17))
 s.append(txt(x+10,570,'gauche → droite',16))
s.extend([txt(60,690,'Chaque signature de couture a deux lignes visuelles communes.',24),txt(60,730,'Pas de rotation : l’encoche supérieure fixe le sens.',22)])
save('p01_seams.svg',s)
s=begin('P02 — matrice de dégâts à reproduire dans les photos')
headers=['Photo','Auvent','Vitre','Enseigne','Cheminée'];xs=[60,240,440,640,840]
for x,h in zip(xs,headers):s.append(txt(x,160,h,24))
keys=['awning','pane','sign','chimney']
for i,k in enumerate(D['p02']['solution']):
 y=240+i*95;s.append(txt(60,y,k,24))
 for x,detail in zip(xs[1:],keys):
  val=D['p02']['observations'][k].get(detail)
  s.append(txt(x,y,'Hors cadre' if val is None else ('Endommagé' if val else 'Intact'),18))
 s.append(line(60,y+30,1100,y+30,'#c4b9a4',2))
s.append(txt(60,800,'Le dommage ne se répare pas pendant la série. Un hors-cadre doit rester hors-cadre.',22))
save('p02_evidence_matrix.svg',s)
s=begin('P04 — masques opaques et union cible')
for i,m in enumerate(D['p04']['masks']):
 x=60+i*370;gridmask(s,m,x,170,40);s.append(txt(x,485,'Calque '+str(i)+' — orientation canonique 0',18))
gridmask(s,D['p04']['target'],60,560,40)
s.append(txt(390,630,'Union cible : tablier et quatre appuis.',24));s.append(txt(390,675,'Axe de rotation = centre de la grille (3,3).',22));s.append(txt(390,715,'Initial : 1, 2, 3 quarts de tour horaires.',22));s.append(txt(390,755,'La texture ne modifie aucun pixel logique.',22))
save('p04_masks.svg',s)
s=begin('P05 — exemple accepté et bras de levier')
p=D['p05'];sol=p['example_solution'];w=170
for i,k in enumerate(sol):
 x=70+i*w;s.append(rect(x,260,155,230,'#fffaf0'));s.append(txt(x+78,300,p['labels'][k],17,'middle'));s.append(txt(x+78,360,p['weights'][k],42,'middle'));s.append(txt(x+78,450,'position '+str(p['positions'][i]),17,'middle'))
s.append(line(65,510,1110,510,ACC,6));s.append('<path d="M 590 510 L 560 565 L 620 565 Z" fill="#a86546"/>')
s.extend([txt(60,650,'Presse et lanterne : deux emplacements centraux, sans arceau bas.',23),txt(60,695,'Médicaments et teintures : pas de voisinage immédiat.',23),txt(60,740,'Équilibre : -6 -8 -6 +1 +10 +9 = 0. Équation réservée au studio.',23),txt(60,800,'Quatre solutions acceptées : ne pas verrouiller ce seul arrangement.',23)])
save('p05_balance.svg',s)
s=begin('P07 — frise de reconstitution et fenêtres')
actions=['Livrer les outils','Relever l’escalier','Déposer le plancher','Étayer le passage','Faire passer le groupe','Détacher la barge']
windows=['Rampe accessible au niveau 0 seulement','Axe accessible au plus tard à 1','Barge à hauteur à partir de 2 ; outils nécessaires','Appuis utilisables à partir de 3 ; plancher posé','Passage avant 5 ; escalier et étais présents','Après le groupe ; conserver le support jusque-là']
for i,(a,b) in enumerate(zip(actions,windows)):
 y=140+i*105;s.append(rect(50,y,1100,90,'#fffaf0'));s.append(txt(85,y+54,i,30));s.append(txt(145,y+38,a,24));s.append(txt(145,y+70,b,18))
s.append(txt(60,850,'Pièce : plancher = 3 travées, toiture = 2, porte = 1 ; interruption = 3.',22))
save('p07_timeline.svg',s)
s=begin('UX — rectangles fonctionnels à 360 × 640 dp',1300,920)
for i,(title,kind) in enumerate([('P03 Routes','routes'),('P05 Barge','barge'),('P07 Frise','timeline')]):
 x=50+i*420;y=140;s.append(rect(x,y,360,640,'#fffaf0'));s.append(txt(x+180,y-20,title,24,'middle'))
 for yy,hh,label in [(0,56,'Retour • titre • menu'),(56,52,'Objectif / fiche'),(108,372,'Zone scène'),(480,88,'Outils locaux'),(568,72,'Carnet • Indice')]:
  s.append(rect(x,y+yy,360,hh));s.append(txt(x+10,y+yy+25,label,16))
 if kind=='routes':
  for r in range(2):
   for c in range(3):s.append(rect(x+48+c*88,y+220+r*88,88,88,'#d6ded7'))
 elif kind=='barge':
  for j in range(6):s.append(rect(x+18+j*54,y+220,48,92,'#d6ded7'))
 else:
  for j in range(6):s.append(rect(x+26,y+160+j*48,308,44,'#d6ded7'))
s.append(txt(50,845,'Surfaces schématiques. Minimum tactile 48 dp. Les textes agrandis font refluer la mise en page.',22))
save('ux_layouts.svg',s)
print('Generated',len(list(OUT.glob('*.svg'))),'SVG engineering plates')
