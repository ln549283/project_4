extends RefCounted
## Rules operate only on contract coordinates. Rendering never determines success.

static func shape(cells: Array, turn: int) -> Array:
	var out: Array = []
	for c: Array in cells:
		var v := Vector2i(int(c[0]), int(c[1]))
		for _i in range(turn):
			v = Vector2i(-v.y, v.x)
		out.append(v)
	var minimum := Vector2i(100, 100)
	for v: Vector2i in out:
		minimum.x = mini(minimum.x, v.x)
		minimum.y = mini(minimum.y, v.y)
	for i in range(out.size()):
		out[i] -= minimum
	return out

static func slide_cells(p: Dictionary, s: Dictionary) -> Array:
	var all_cells: Array = []
	for i in range(p.bars.size()):
		var b: Dictionary = p.bars[i]
		var cells: Array = []
		for j in range(int(b.length)):
			cells.append(Vector2i(int(s.positions[i]) + j, int(b.lane)) if b.axis == "h" else Vector2i(int(b.lane), int(s.positions[i]) + j))
		all_cells.append(cells)
	return all_cells

static func occupancy(p: Dictionary, s: Dictionary) -> Dictionary:
	var cells: Dictionary = {}
	var groups: Array = []
	if p.kind == "slide":
		groups = slide_cells(p, s)
	elif p.kind == "packing":
		for i in range(p.pieces.size()):
			var pos: Array = s.placements[i]
			var group: Array = []
			if int(pos[0]) >= 0:
				for c: Vector2i in shape(p.pieces[i], int(pos[2])):
					group.append(c + Vector2i(int(pos[0]), int(pos[1])))
			groups.append(group)
	for i in range(groups.size()):
		for cell: Vector2i in groups[i]:
			if cell.x < 0 or cell.y < 0 or cell.x >= int(p.cols) or cell.y >= int(p.rows) or cells.has(cell):
				return {"ok": false, "cells": cells}
			cells[cell] = i
	return {"ok": true, "cells": cells}

static func _ints(value: Variant, size: int, lo: int, hi: int, unique: bool = false) -> bool:
	if not value is Array or value.size() != size:
		return false
	var seen: Dictionary = {}
	for n: Variant in value:
		if not (n is int or n is float) or float(n) != floor(float(n)) or int(n) < lo or int(n) > hi or (unique and seen.has(int(n))):
			return false
		seen[int(n)] = true
	return true

static func valid_state(p: Dictionary, s: Dictionary) -> bool:
	match str(p.kind):
		"facades", "ropes":
			if not _ints(s.get("order"), 6, 0, 5, true): return false
			if p.kind == "ropes":
				for i: Variant in p.fixed:
					if int(s.order[int(i)]) != int(i): return false
		"slide":
			if not _ints(s.get("positions"), p.bars.size(), 0, 5): return false
			return occupancy(p, s).ok
		"packing":
			if not s.get("placements") is Array or s.placements.size() != p.pieces.size(): return false
			for pos: Variant in s.placements:
				if not _ints(pos, 3, -1, 5) or int(pos[2]) < 0 or int(pos[2]) > 3: return false
				if (int(pos[0]) == -1) != (int(pos[1]) == -1): return false
			return occupancy(p, s).ok
		"pour":
			if not _ints(s.get("volumes"), 3, 0, 8): return false
			var total := 0
			for i in range(3):
				if int(s.volumes[i]) > int(p.capacities[i]): return false
				total += int(s.volumes[i])
			return total == 8
		"light":
			return _ints(s.get("turns"), p.mirrors.size(), 0, 1)
		"fold":
			return _ints(s.get("turns"), p.lengths.size(), 0, 3)
		"supports":
			if not s.get("chosen") is Array or not _ints(s.chosen, s.chosen.size(), 1, int(p.span) - 1, true): return false
			if s.chosen.size() > int(p.count): return false
			for n: Variant in s.chosen:
				if has_number(p.forbidden,int(n)): return false
		"ferry":
			return _ints(s.get("bank"), 4, 0, 1) and _ints([s.get("boat")], 1, 0, 1)
		"gauges":
			return _ints(s.get("offsets"), 4, 0, int(p.max_offset)) and int(s.offsets[0]) == 0
		_:
			return false
	return true

static func act(p: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	if not valid_state(p, state): return {"ok": false, "message": "État invalide."}
	var s := state.duplicate(true)
	var a := int(action.get("a", -1))
	var b := int(action.get("b", -1))
	match str(p.kind):
		"facades", "ropes":
			if a < 0 or b < 0 or a >= 6 or b >= 6: return {"ok": false}
			if p.kind == "ropes" and (has_number(p.fixed,a) or has_number(p.fixed,b)): return {"ok": false, "message": "Ce taquet est fixé au quai."}
			var old: Variant = s.order[a]
			s.order[a] = s.order[b]
			s.order[b] = old
		"slide":
			if a < 0 or a >= s.positions.size() or b not in [-1, 1]: return {"ok": false}
			s.positions[a] = int(s.positions[a]) + b
		"packing":
			if a < 0 or a >= s.placements.size(): return {"ok": false}
			s.placements[a] = action.get("placement", [-1, -1, 0]).duplicate()
		"pour":
			if a < 0 or b < 0 or a >= 3 or b >= 3 or a == b: return {"ok": false}
			var amount := mini(int(s.volumes[a]), int(p.capacities[b]) - int(s.volumes[b]))
			if amount == 0: return {"ok": false, "message": "La source est vide ou la destination pleine."}
			s.volumes[a] = int(s.volumes[a]) - amount
			s.volumes[b] = int(s.volumes[b]) + amount
		"light", "fold":
			if a < 0 or a >= s.turns.size(): return {"ok": false}
			s.turns[a] = posmod(int(s.turns[a]) + 1, 2 if p.kind == "light" else 4)
		"supports":
			if has_number(s.chosen,a):
				s.chosen.remove_at(index_of(s.chosen,a))
			else:
				s.chosen.append(a)
		"ferry":
			var crew: Variant = action.get("crew", [])
			if not _ints(crew, crew.size() if crew is Array else 0, 0, 3, true): return {"ok": false}
			var weight := 0
			var rower := false
			for i: Variant in crew:
				if int(s.bank[int(i)]) != int(s.boat): return {"ok": false, "message": "Cet élément est sur l'autre rive."}
				weight += int(p.weights[int(i)])
				rower = rower or has_number(p.rowers,int(i))
			if not rower or weight > int(p.capacity): return {"ok": false, "message": "Il faut un secouriste à bord et au plus trois unités de charge."}
			for i: Variant in crew:
				s.bank[int(i)] = 1 - int(s.boat)
			s.boat = 1 - int(s.boat)
		"gauges":
			if a < 1 or a > 3 or b not in [-1, 1]: return {"ok": false}
			s.offsets[a] = int(s.offsets[a]) + b
	if not valid_state(p, s): return {"ok": false, "message": "Le mouvement rencontre un obstacle ou sort du logement."}
	return {"ok": true, "state": s}

static func _point(v: Array) -> Vector2i:
	return Vector2i(int(v[0]), int(v[1]))

static func light_trace(p: Dictionary, s: Dictionary) -> Dictionary:
	var pos := _point(p.source)
	var direction := _point(p.direction)
	var path: Array = [pos]
	var seen: Dictionary = {}
	var marks: Dictionary = {}
	for _step in range(100):
		pos += direction
		path.append(pos)
		for mark: Array in p.marks:
			if pos == _point(mark): marks[pos] = true
		if pos.x < 0 or pos.y < 0 or pos.x >= int(p.cols) or pos.y >= int(p.rows):
			return {"valid": pos == _point(p.target) and marks.size() == p.marks.size(), "path": path, "marks": marks.size()}
		var key := str(pos) + str(direction)
		if seen.has(key): break
		seen[key] = true
		for i in range(p.mirrors.size()):
			if pos == _point(p.mirrors[i]):
				direction = Vector2i(-direction.y, -direction.x) if int(s.turns[i]) == 0 else Vector2i(direction.y, direction.x)
	return {"valid": false, "path": path, "marks": marks.size()}

static func fold_trace(p: Dictionary, s: Dictionary) -> Dictionary:
	var pos := _point(p.start)
	var seen: Dictionary = {pos: true}
	var path: Array = [pos]
	for i in range(p.lengths.size()):
		var direction: Vector2i = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP][int(s.turns[i])]
		for _j in range(int(p.lengths[i])):
			pos += direction
			path.append(pos)
			var blocked := false
			for cell: Array in p.blocked:
				blocked = blocked or pos == _point(cell)
			if pos.x < 0 or pos.y < 0 or pos.x >= int(p.cols) or pos.y >= int(p.rows) or seen.has(pos) or blocked:
				return {"valid": false, "path": path, "collision": true}
			seen[pos] = true
	return {"valid": pos == _point(p.target), "path": path, "collision": false}

static func _cross(a: Vector2, b: Vector2, c: Vector2) -> float:
	return (b - a).cross(c - a)

static func _on(a: Vector2, b: Vector2, c: Vector2) -> bool:
	return is_zero_approx(_cross(a, b, c)) and c.x >= minf(a.x, b.x) and c.x <= maxf(a.x, b.x) and c.y >= minf(a.y, b.y) and c.y <= maxf(a.y, b.y)

static func _crosses(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool:
	return (_cross(a,b,c) * _cross(a,b,d) < 0 and _cross(c,d,a) * _cross(c,d,b) < 0) or _on(a,b,c) or _on(a,b,d) or _on(c,d,a) or _on(c,d,b)

static func rope_conflicts(p: Dictionary, s: Dictionary) -> int:
	var points: Array = []
	for i in range(6): points.append(Vector2(_point(p.points[index_of(s.order,i)])))
	var count := 0
	for edge: Array in p.edges:
		for i in range(6):
			if not has_number(edge,i) and _on(points[int(edge[0])], points[int(edge[1])], points[i]): count += 1
	for i in range(p.edges.size()):
		var e: Array = p.edges[i]
		for j in range(i + 1, p.edges.size()):
			var f: Array = p.edges[j]
			if e[0] in f or e[1] in f: continue
			if _crosses(points[int(e[0])], points[int(e[1])], points[int(f[0])], points[int(f[1])]): count += 1
	return count

static func validate(p: Dictionary, s: Dictionary) -> Dictionary:
	if not valid_state(p, s): return {"valid": false, "message": "État incomplet ou invalide."}
	var ok := false
	var message := "Comparez votre montage aux repères visibles."
	match str(p.kind):
		"facades":
			ok = true
			for clue: Array in p.clues:
				var a: int = index_of(s.order,int(clue[1]))
				var b: int = index_of(s.order,int(clue[2]))
				ok = ok and ((b == a + 1 and a / 3 == b / 3) if clue[0] == "right" else b == a + 3)
			message = "Un voisinage ne correspond pas aux croquis."
		"slide":
			ok = int(s.positions[0]) == int(p.cols) - int(p.bars[0].length)
			message = "La chemise n'a pas encore rejoint l'ouverture."
		"packing":
			ok = occupancy(p, s).cells.size() == int(p.cols) * int(p.rows)
			message = "Le coffre contient encore des espaces vides."
		"ropes":
			ok = rope_conflicts(p, s) == 0
			message = "Des cordes se croisent ou passent sur un autre taquet."
		"pour":
			ok = true
			for i in range(3): ok = ok and int(s.volumes[i]) == int(p.target[i])
			message = "Les deux réserves ne contiennent pas encore quatre litres chacune."
		"light":
			ok = light_trace(p, s).valid
			message = "Le rayon doit traverser les trois repères et rejoindre le quai."
		"fold":
			ok = fold_trace(p, s).valid
			message = "L'escalier rencontre un obstacle ou manque l'attache d'arrivée."
		"supports":
			var supports: Array = s.chosen.duplicate()
			supports.append(0)
			supports.append(int(p.span))
			supports.sort()
			ok = s.chosen.size() == int(p.count)
			for h: Variant in p.heavy: ok = ok and has_number(supports,int(h))
			for i in range(supports.size() - 1): ok = ok and int(supports[i + 1]) - int(supports[i]) <= int(p.max_gap)
			message = "Une charge lourde manque d'appui, ou une portée dépasse trois intervalles."
		"ferry":
			ok = s.bank.all(func(v: Variant) -> bool: return int(v) == 1)
			message = "Des personnes ou des caisses attendent encore sur la rive de départ."
		"gauges":
			ok = true
			for c: Dictionary in p.links:
				ok = ok and int(s.offsets[int(c.a)]) + int(c.ma) == int(s.offsets[int(c.b)]) + int(c.mb)
			message = "Les marques communes ne sont pas toutes à la même hauteur."
	return {"valid": ok, "message": "Reconstitution cohérente." if ok else message}

static func index_of(values: Array, value: int) -> int:
	for i in range(values.size()):
		if int(values[i]) == value: return i
	return -1

static func has_number(values: Array, value: int) -> bool:
	return index_of(values,value) >= 0
