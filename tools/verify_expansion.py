#!/usr/bin/env python3
"""Independent exhaustive/reference solvers for the ten additional puzzles."""
import itertools,json,collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
D=json.loads((ROOT/'design/puzzles.json').read_text())

def bfs(start,neighbors,goal):
 q=collections.deque([start]);seen={start:None};moves={}
 while q:
  s=q.popleft()
  if goal(s):
   path=[];end=s
   while seen[s] is not None:path.append(moves[s]);s=seen[s]
   return end,path[::-1],len(seen)
  for m,t in neighbors(s):
   if t not in seen:seen[t]=s;moves[t]=m;q.append(t)
 raise AssertionError('unreachable')

def slide_cells(p,s):
 cells=[]
 for b,v in zip(p['bars'],s):
  cells.append([(v+j,b['lane']) if b['axis']=='h' else (b['lane'],v+j) for j in range(b['length'])])
 return cells

def slide_valid(p,s):
 flat=sum(slide_cells(p,s),[])
 return len(set(flat))==len(flat) and all(0<=x<p['cols'] and 0<=y<p['rows'] for x,y in flat)

def slide_neighbors(p,s):
 for i in range(len(s)):
  for dx in [-1,1]:
   t=list(s);t[i]+=dx
   if slide_valid(p,t):yield [i,dx],tuple(t)

def rotated(cells,r):
 for _ in range(r):cells=[(-y,x) for x,y in cells]
 x0=min(x for x,y in cells);y0=min(y for x,y in cells)
 return [(x-x0,y-y0) for x,y in cells]

def packing(p):
 choices=[]
 for piece in p['pieces']:
  seen=set();opts=[]
  for r in range(4):
   shape=rotated(piece,r)
   for y in range(p['rows']-max(b for a,b in shape)):
    for x in range(p['cols']-max(a for a,b in shape)):
     cells=frozenset((x+a,y+b) for a,b in shape)
     if cells not in seen:opts.append(([x,y,r],cells));seen.add(cells)
  choices.append(opts)
 sols=[];examined=0
 def visit(i,used,placed):
  nonlocal examined
  examined+=1
  if i==len(choices):sols.append(placed);return
  for pos,cells in choices[i]:
   if not used&cells:visit(i+1,used|cells,placed+[pos])
 visit(0,set(),[])
 return sols,examined

def crosses(a,b,c,d):
 def cross(u,v,w):return (v[0]-u[0])*(w[1]-u[1])-(v[1]-u[1])*(w[0]-u[0])
 # Intersections including collinear overlap; shared vertices handled by caller.
 def on(u,v,w):return cross(u,v,w)==0 and min(u[0],v[0])<=w[0]<=max(u[0],v[0]) and min(u[1],v[1])<=w[1]<=max(u[1],v[1])
 return (cross(a,b,c)*cross(a,b,d)<0 and cross(c,d,a)*cross(c,d,b)<0) or any([on(a,b,c),on(a,b,d),on(c,d,a),on(c,d,b)])

def ropes_ok(p,o):
 points=[p['points'][o.index(i)] for i in range(len(o))]
 for a,b in p['edges']:
  for i,pt in enumerate(points):
   if i not in (a,b) and crosses(points[a],points[b],pt,pt):return False
 for (a,b),(c,d) in itertools.combinations(p['edges'],2):
  if {a,b}&{c,d}:continue
  if crosses(points[a],points[b],points[c],points[d]):return False
 return True

def light(p,turns):
 x,y=p['source'];dx,dy=p['direction'];seen=set();marks=set();path=[[x,y]]
 for _ in range(100):
  x+=dx;y+=dy;path.append([x,y])
  if [x,y] in p['marks']:marks.add(tuple([x,y]))
  if not(0<=x<p['cols'] and 0<=y<p['rows']):return [x,y]==p['target'] and len(marks)==len(p['marks']),path
  if (x,y,dx,dy) in seen:return False,path
  seen.add((x,y,dx,dy))
  if [x,y] in p['mirrors']:
   i=p['mirrors'].index([x,y]);dx,dy=(-dy,-dx) if turns[i]==0 else (dy,dx)
 return False,path

def fold(p,turns):
 x,y=p['start'];seen={(x,y)};path=[[x,y]]
 for n,r in zip(p['lengths'],turns):
  dx,dy=[(1,0),(0,1),(-1,0),(0,-1)][r]
  for _ in range(n):
   x+=dx;y+=dy
   if not(0<=x<p['cols'] and 0<=y<p['rows']) or [x,y] in p['blocked'] or (x,y) in seen:return False,path
   seen.add((x,y));path.append([x,y])
 return [x,y]==p['target'],path

def solve():
 reports={}
 p=D['p08'];sol=[]
 for o in itertools.permutations(range(6)):
  def clue(c):
   typ,a,b=c;i=o.index(a);j=o.index(b)
   return (j==i+1 and i//3==j//3) if typ=='right' else j==i+3
  if all(clue(c) for c in p['clues']):sol.append(list(o))
 assert len(sol)==1;reports['p08']={'count':len(sol),'examined':720,'solution':{'order':sol[0]}}
 p=D['p09'];start=tuple(p['initial']['positions']);assert slide_valid(p,start),'drawer initial overlap'
 end,path,n=bfs(start,lambda s:slide_neighbors(p,s),lambda s:s[0]==p['cols']-p['bars'][0]['length'])
 reports['p09']={'examined':n,'moves':path,'minimum_moves':len(path),'solution':{'positions':list(end)}}
 p=D['p10'];sol,n=packing(p);assert sol;reports['p10']={'count':len(sol),'examined':n,'solution':{'placements':sol[0]}}
 p=D['p11'];sol=[]
 for o in itertools.permutations(range(6)):
  if all(o[i]==i for i in p['fixed']) and ropes_ok(p,o):sol.append(list(o))
 assert sol;reports['p11']={'count':len(sol),'examined':24,'solution':{'order':sol[0]}}
 p=D['p12']
 def pours(s):
  for a,b in itertools.permutations(range(3),2):
   v=min(s[a],p['capacities'][b]-s[b]);t=list(s);t[a]-=v;t[b]+=v
   if v:yield [a,b],tuple(t)
 end,path,n=bfs(tuple(p['initial']['volumes']),pours,lambda s:list(s)==p['target']);reports['p12']={'examined':n,'minimum_moves':len(path),'moves':path,'solution':{'volumes':list(end)}}
 p=D['p13'];sol=[list(s) for s in itertools.product(range(2),repeat=len(p['mirrors'])) if light(p,s)[0]]
 assert sol;reports['p13']={'count':len(sol),'examined':64,'solution':{'turns':sol[0]}}
 p=D['p14'];sol=[list(s) for s in itertools.product(range(4),repeat=len(p['lengths'])) if fold(p,s)[0]]
 assert sol;reports['p14']={'count':len(sol),'examined':256,'solution':{'turns':sol[0]}}
 p=D['p15'];sol=[]
 for s in itertools.combinations([i for i in range(1,p['span']) if i not in p['forbidden']],p['count']):
  points=[0,*s,p['span']]
  if all(h in points for h in p['heavy']) and max(b-a for a,b in zip(points,points[1:]))<=p['max_gap']:sol.append(list(s))
 assert sol;reports['p15']={'count':len(sol),'solution':{'chosen':sol[0]}}
 p=D['p16']
 def sail(s):
  bank=s[:4];boat=s[4];available=[i for i,b in enumerate(bank) if b==boat]
  for n in range(1,4):
   for crew in itertools.combinations(available,n):
    if not any(i in p['rowers'] for i in crew) or sum(p['weights'][i] for i in crew)>p['capacity']:continue
    t=list(bank)
    for i in crew:t[i]=1-boat
    yield list(crew),tuple(t+[1-boat])
 end,path,n=bfs((0,0,0,0,0),sail,lambda s:all(s[:4]));reports['p16']={'examined':n,'minimum_moves':len(path),'moves':path,'solution':{'bank':list(end[:4]),'boat':end[4]}}
 p=D['p17'];sol=[]
 for s in itertools.product(range(p['max_offset']+1),repeat=3):
  s=(0,*s)
  if all(s[c['a']]+c['ma']==s[c['b']]+c['mb'] for c in p['links']):sol.append(list(s))
 assert len(sol)==1;reports['p17']={'count':len(sol),'examined':125,'solution':{'offsets':sol[0]}}
 return reports

if __name__=='__main__':
 import sys
 report=solve()
 if '--write-solutions' in sys.argv:
  for k,r in report.items():D[k]['solution']=r['solution'];D[k]['solution_moves']=r.get('moves',[])
  for path in ['design/puzzles.json','content/puzzles.json']:(ROOT/path).write_text(json.dumps(D,ensure_ascii=False,indent=2)+'\n')
 else:
  for k,r in report.items():assert D[k]['solution']==r['solution'],k
 (ROOT/'design/expansion_verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 for k,r in report.items():print(k,{a:b for a,b in r.items() if a not in ['moves','solution']})
