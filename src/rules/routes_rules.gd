class_name RoutesRules
extends RefCounted

const DELTA := {
	"N": Vector2i(-1, 0),
	"E": Vector2i(0, 1),
	"S": Vector2i(1, 0),
	"W": Vector2i(0, -1),
}
const OPPOSITE := {"N": "S", "E": "W", "S": "N", "W": "E"}

static func validate(bits: Array, contract: Dictionary, tile_pairs: Dictionary) -> Dictionary:
	var violations: Array = []
	var rows := int(contract.get("rows", 0))
	var cols := int(contract.get("cols", 0))
	if bits.size() != rows * cols:
		violations.append({"rule_id": "p03_complete_grid", "evidence_id": "evidence_delivery", "params": {}})
		return _result(violations)

	var routes: Array = contract.get("routes", [])
	var resolved: Dictionary = {}
	for raw_route: Variant in routes:
		var route: Dictionary = raw_route
		var trace_result := trace(bits, rows, cols, route.get("start", []), tile_pairs)
		resolved[str(route.get("id", ""))] = trace_result
		if trace_result.get("loop", false):
			violations.append({"rule_id": "p03_route_loop", "evidence_id": "evidence_delivery", "params": {"route": route.get("id", "")}})
			continue
		if trace_result.get("end", []) != route.get("end", []):
			violations.append({
				"rule_id": "p03_wrong_destination",
				"evidence_id": "evidence_delivery",
				"params": {"route": route.get("id", ""), "end": trace_result.get("end", [])},
			})
	return {"valid": violations.is_empty(), "violations": violations, "resolved_state": resolved}

static func trace(bits: Array, rows: int, cols: int, start: Array, tile_pairs: Dictionary) -> Dictionary:
	if start.size() != 3:
		return {"end": [], "visited": [], "loop": false}
	var r := int(start[0])
	var c := int(start[1])
	var side := str(start[2])
	var visited: Array = []
	var seen: Dictionary = {}
	while true:
		var key := "%d,%d,%s" % [r, c, side]
		if seen.has(key):
			return {"end": [], "visited": visited, "loop": true}
		seen[key] = true
		visited.append([r, c, side])
		var bit := int(bits[r * cols + c])
		var pair_map := _pair_map(tile_pairs.get(str(bit), []))
		if not pair_map.has(side):
			return {"end": [], "visited": visited, "loop": false}
		var out_side := str(pair_map[side])
		var d: Vector2i = DELTA[out_side]
		var rr := r + d.x
		var cc := c + d.y
		if rr < 0 or rr >= rows or cc < 0 or cc >= cols:
			return {"end": [r, c, out_side], "visited": visited, "loop": false}
		r = rr
		c = cc
		side = str(OPPOSITE[out_side])

static func _pair_map(raw_pairs: Array) -> Dictionary:
	var result: Dictionary = {}
	for raw_pair: Variant in raw_pairs:
		var pair: Array = raw_pair
		if pair.size() == 2:
			result[str(pair[0])] = str(pair[1])
			result[str(pair[1])] = str(pair[0])
	return result

static func _result(violations: Array) -> Dictionary:
	return {"valid": violations.is_empty(), "violations": violations, "resolved_state": {}}
