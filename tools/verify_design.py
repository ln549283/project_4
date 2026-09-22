#!/usr/bin/env python3
"""Design-only exhaustive checks. No Godot runtime or external dependencies."""
from itertools import permutations, product
from pathlib import Path
import json
D = json.loads((Path(__file__).resolve().parents[1] / 'design/puzzles.json').read_text())

def trace(bits, rows, cols, start):
    pairs = [{s:t for a,b in D['route_tile_pairs'][str(i)] for s,t in ((a,b),(b,a))} for i in range(2)]
    r,c,side = start
    visited = []
    while (r,c,side) not in visited:
        visited.append((r,c,side))
        out = pairs[bits[r*cols+c]][side]
        dr,dc,op = {'N':(-1,0,'S'),'E':(0,1,'W'),'S':(1,0,'N'),'W':(0,-1,'E')}[out]
        rr,cc = r+dr,c+dc
        if not (0 <= rr < rows and 0 <= cc < cols):
            return [r,c,out], visited
        r,c,side = rr,cc,op
    return None, visited

def rotate(m,n):
    for _ in range(n): m = [''.join(row) for row in zip(*m[::-1])]
    return m

def union(masks):
    n=len(masks[0])
    return [''.join('1' if any(m[y][x]=='1' for m in masks) else '0' for x in range(n)) for y in range(n)]

def main():
    report=[]
    def record(name, space, sols, expected):
        assert len(sols)==expected, (name,len(sols),sols)
        report.append({'puzzle':name,'states_examined':space,'accepted_count':len(sols),'accepted':sols})
    p=D['p01']; sols=[]
    for order in permutations(p['pieces']):
        edge=p['left_anchor']
        for k in order:
            left,right=p['pieces'][k]
            if edge!=left: break
            edge=right
        else:
            if edge==p['right_anchor']:sols.append(list(order))
    record('p01',120,sols,1); assert sols[0]==p['solution']
    p=D['p02']; sols=[]
    for order in permutations(p['observations']):
        last={}; valid=True
        for k in order:
            for detail,state in p['observations'][k].items():
                if state<last.get(detail,0):valid=False
                last[detail]=state
        if valid:sols.append(list(order))
    record('p02',120,sols,1); assert sols[0]==p['solution']
    for name in ('p03','p06'):
        p=D[name]; sols=[]
        for bits in product(range(2),repeat=p['rows']*p['cols']):
            if all(trace(bits,p['rows'],p['cols'],r['start'])[0]==r['end'] for r in p['routes']):sols.append(list(bits))
        record(name,2**(p['rows']*p['cols']),sols,1); assert sols[0]==p['solution']; assert p['initial'] not in sols
        used=set()
        for r in p['routes']:
            end,path=trace(p['solution'],p['rows'],p['cols'],r['start'])
            used|={(a,b) for a,b,_ in path}
            report[-1].setdefault('paths',[]).append({'route':r['id'],'visited':path,'end':end})
        assert len(used)==p['rows']*p['cols'], (name,'unused tiles',used)
    p=D['p04']; sols=[]
    for turns in product(range(4),repeat=3):
        if union([rotate(m,n) for m,n in zip(p['masks'],turns)])==p['target']:sols.append(list(turns))
    record('p04',64,sols,1); assert sols[0]==p['solution']; assert p['initial'] not in sols
    p=D['p05']; sols=[]
    for order in permutations(p['weights']):
        if any(abs(p['positions'][order.index(k)])!=1 for k in p['central_only']):continue
        a,b=p['not_adjacent']
        if abs(order.index(a)-order.index(b))==1:continue
        if sum(p['positions'][i]*p['weights'][k] for i,k in enumerate(order))==0:sols.append(list(order))
    record('p05',720,sols,p['solution_count']); assert p['example_solution'] in sols
    p=D['p07']; donors=[k for k,n in p['donors'].items() if n==p['gap']]
    assert donors==[p['donor_solution']]
    sols=[]
    for seq in permutations(p['actions'],p['slots']):
        if set(seq)!=set(p['required_actions']):continue
        pos={k:seq.index(k) for k in seq}
        if any(not lo<=pos[k]<=hi for k,(lo,hi) in p['windows'].items()):continue
        if any(pos[a]>=pos[b] for a,b in p['before']):continue
        sols.append(list(seq))
    record('p07',20160,sols,1); assert sols[0]==p['solution']
    # Both branch orders reach ending, and no monotone state can lose availability.
    deps=D['progression']; orders=[]
    def visit(done,order):
        if len(done)==len(deps):orders.append(order);return
        available=[k for k,v in deps.items() if k not in done and set(v)<=done]
        assert available, ('deadlock',done)
        for k in available:visit(done|{k},order+[k])
    visit(set(),[]); assert len(orders)==2
    result={'design_version':D['design_version'],'checks':'PASS','note':'Combinatorial design checks; not human playtests or Android tests.','puzzles':report,'progression_orders':orders}
    target=Path(__file__).resolve().parents[1]/'design/verification_report.json'
    target.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    for r in report:print(f"{r['puzzle']}: {r['states_examined']} states, {r['accepted_count']} accepted")
    print('Progression: two valid orders, no prerequisite deadlock. PASS')
if __name__=='__main__':main()
