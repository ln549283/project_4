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

def paths_for_map(p,water,placement,group):
    edges=list(p['edges'])
    for fragment,gap in placement.items():
        if gap is not None:
            f=p['fragments'][fragment]
            edges.append({'ends':p['gaps'][gap]['ends'],'clearance':f['clearance'],'stairs':f['stairs']})
    g=p['groups'][group];adj={n:[] for n in p['nodes']}
    for e in edges:
        if water>=e['clearance'] or (e['stairs'] and not g['stairs_allowed']):continue
        a,b=e['ends'];adj[a].append(b);adj[b].append(a)
    result=[]
    def visit(path):
        if path[-1]==g['goal']:result.append(path);return
        for n in adj[path[-1]]:
            if n not in path:visit(path+[n])
    visit([g['start']]);return result

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
    for name in ('p03',):
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
        if sum(p['positions'][i]*p['weights'][k] for i,k in enumerate(order))==0:sols.append(list(order))
    record('p05',720,sols,p['solution_count']); assert p['example_solution'] in sols
    # P06: exhaustive placements plus independent simple-path enumeration.
    p=D['p06']; maps=[]; all_route_solutions=[]
    for water,arcade,ramp in product(p['water_levels'],[None]+p['fragments']['arcade']['destinations'],[None]+p['fragments']['ramp']['destinations']):
        placement={'arcade':arcade,'ramp':ramp}
        routes={g:paths_for_map(p,water,placement,g) for g in p['groups']}
        if water==p['observed_water_level'] and arcade and ramp and all(routes.values()):
            maps.append({'water_level':water,'fragments':placement})
            all_route_solutions.append(routes)
    record('p06',54,maps,1)
    assert maps[0]=={k:p['solution'][k] for k in ('water_level','fragments')}
    for g,paths in all_route_solutions[0].items():
        assert sorted(paths)==sorted(p['accepted_route_variants'][g]),(g,paths)
    report[-1]['accepted_routes']=all_route_solutions[0]
    report[-1]['complete_route_combinations']=2
    # Wrong water, stairs and private shortcuts have explicit counterexamples.
    assert not paths_for_map(p,4,{'arcade':'sc','ramp':'ag'},'infirmary')
    assert paths_for_map(p,3,{'arcade':None,'ramp':None},'infirmary')==[['I','H']]
    p=D['p07']; q=p['requirements']; donors=[k for k,v in p['donors'].items() if v['span']==q['span'] and v['width']>=q['min_width'] and v['flat']==q['flat'] and v['paired_fasteners']==q['paired_fasteners']]
    assert donors==[p['donor_solution']]
    sols=[]
    for seq in permutations(p['actions'],p['slots']):
        if set(seq)!=set(p['actions']):continue
        pos={k:seq.index(k) for k in seq}
        if any(not lo<=pos[k]<=hi for k,(lo,hi) in p['windows'].items()):continue
        if any(pos[a]>=pos[b] for a,b in p['before']):continue
        sols.append(list(seq))
    record('p07',720,sols,1); assert sols[0]==p['solution']
    # Both branch orders reach ending, and no monotone state can lose availability.
    deps=D['progression']; orders=[]
    def visit(done,order):
        if len(done)==len(deps):orders.append(order);return
        available=[k for k,v in deps.items() if k not in done and set(v)<=done]
        assert available, ('deadlock',done)
        for k in available:visit(done|{k},order+[k])
    visit(set(),[]); assert len(orders)==2
    # Every required piece of evidence must already be granted when an entry is legal.
    evidence=json.loads((Path(__file__).resolve().parents[1]/'design/evidence.json').read_text())
    states=set()
    for order in orders:
        done=set()
        for stage in order:
            available={e['id'] for e in evidence['items'] if set(e['requires_solved'])<=done}
            missing=set(evidence['required_by_stage'].get(stage,[]))-available
            assert not missing,(stage,missing)
            states.add(tuple(sorted(done)));done.add(stage)
        states.add(tuple(sorted(done)))
    hints=json.loads((Path(__file__).resolve().parents[1]/'design/hints_fr.json').read_text())
    assert set(hints)=={f'p{i:02}' for i in range(1,18)} and all(len(v)==3 for v in hints.values())
    # Document/manifest integrity remains part of the design handoff.
    import csv,re
    root=Path(__file__).resolve().parents[1]
    assets=list(csv.DictReader((root/'design/assets.csv').open()))
    assert len({a['id'] for a in assets})==len(assets)
    assert len({a['runtime_path'] for a in assets})==len(assets)
    bible=(root/'ASSET_BIBLE.md').read_text()
    for a in assets:
        assert '| '+a['id']+' |' in bible,a['id']
        assert a['scope'] in ('required_v1','ignore_v1')
        assert a['quality'] in ('hero','secondary','ui','variant','mechanical')
    prose=(root/'docs/PUZZLES.md').read_text()
    for stage,ladder in hints.items():
        for hint in ladder:assert hint in prose,(stage,hint)
    for doc in root.rglob('*.md'):
        for href in re.findall(r'\]\(([^)]+)\)',doc.read_text()):
            if '://' not in href and not href.startswith('#'):
                assert (doc.parent/href.split('#')[0]).exists(),(doc,href)
    from verify_expansion import solve
    expansion=solve()
    for stage,checks in expansion.items():
        assert D[stage]['solution']==checks['solution']
    result={'expansion':expansion,'design_version' :D['design_version'],'checks':'PASS','note':'Combinatorial design checks; not human playtests or Android tests.','puzzles':report,'progression_orders':orders,'reachable_progression_states':len(states),'evidence_availability':'PASS for both branch orders','hints':51,'asset_manifest':{'entries':len(assets),'required_v1':sum(a['scope']=='required_v1' for a in assets),'ignored_v1':sum(a['scope']=='ignore_v1' for a in assets)},'document_links':'PASS','hint_text_parity':'PASS'}
    target=Path(__file__).resolve().parents[1]/'design/verification_report.json'
    target.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    for r in report:print(f"{r['puzzle']}: {r['states_examined']} states, {r['accepted_count']} accepted")
    print('Progression: two valid orders, no prerequisite deadlock. PASS')
if __name__=='__main__':main()
