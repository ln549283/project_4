class_name FloodMapRules
extends RefCounted

static func validate(state: Dictionary, contract: Dictionary) -> Dictionary:
	var violations: Array = []
	var water := int(state.get("water_level", -1))
	if water != int(contract.get("observed_water_level", -2)):
		violations.append({"rule_id": "p06_water_level", "evidence_id": "evidence_photo_f3", "params": {"water_level": water}})
		return _result(violations)

	var placements: Dictionary = state.get("fragments", {})
	for fragment_id in contract.get("fragments", {}).keys():
		var target: Variant = placements.get(fragment_id)
		if target == null:
			violations.append({"rule_id": "p06_fragment_missing", "evidence_id": "evidence_refuges", "params": {"fragment": fragment_id}})
			return _result(violations)
		var destinations: Array = contract["fragments"][fragment_id].get("destinations", [])
		if str(target) not in destinations:
			violations.append({"rule_id": "p06_fragment_incompatible", "evidence_id": "evidence_refuges", "params": {"fragment": fragment_id, "target": target}})
			return _result(violations)

	var routes: Dictionary = state.get("routes", {})
	for group_id in contract.get("groups", {}).keys():
		var path: Array = routes.get(group_id, [])
		var route_check := validate_route(str(group_id), path, water, placements, contract)
		if not route_check.get("valid", false):
			return route_check
	return {"valid": true, "violations": [], "resolved_state": state.duplicate(true)}

static func validate_route(group_id: String, path: Array, water: int, placements: Dictionary, contract: Dictionary) -> Dictionary:
	var groups: Dictionary = contract.get("groups", {})
	if not groups.has(group_id):
		return _single("p06_unknown_group", "evidence_refuges", {"group": group_id})
	var group: Dictionary = groups[group_id]
	if path.is_empty() or str(path[0]) != str(group.get("start", "")) or str(path[path.size() - 1]) != str(group.get("goal", "")):
		return _single("p06_origin_or_destination", "evidence_refuges", {"group": group_id})

	var seen: Dictionary = {}
	for raw_node: Variant in path:
		var node := str(raw_node)
		if not contract.get("nodes", {}).has(node):
			return _single("p06_unknown_node", "evidence_refuges", {"node": node})
		if seen.has(node):
			return _single("p06_route_repeats_node", "evidence_refuges", {"node": node})
		seen[node] = true

	var edges := _active_edges(placements, contract)
	for i in range(path.size() - 1):
		var a := str(path[i])
		var b := str(path[i + 1])
		var edge := _find_edge(a, b, edges)
		if edge.is_empty():
			return _single("p06_missing_link", "evidence_refuges", {"from": a, "to": b})
		if water >= int(edge.get("clearance", 0)):
			return _single("p06_flooded_link", "evidence_photo_f3", {"from": a, "to": b})
		if bool(edge.get("stairs", false)) and not bool(group.get("stairs_allowed", true)):
			return _single("p06_stairs_forbidden", "evidence_refuges", {"group": group_id, "from": a, "to": b})
	return {"valid": true, "violations": [], "resolved_state": {"route": path.duplicate()}}

static func _active_edges(placements: Dictionary, contract: Dictionary) -> Array:
	var result: Array = []
	for raw_edge: Variant in contract.get("edges", []):
		result.append((raw_edge as Dictionary).duplicate(true))
	var fragments: Dictionary = contract.get("fragments", {})
	var gaps: Dictionary = contract.get("gaps", {})
	for fragment_id in fragments.keys():
		var target: Variant = placements.get(fragment_id)
		if target == null or not gaps.has(str(target)):
			continue
		var fragment: Dictionary = fragments[fragment_id]
		var gap: Dictionary = gaps[str(target)]
		result.append({
			"ends": gap.get("ends", []).duplicate(),
			"clearance": fragment.get("clearance", 0),
			"stairs": fragment.get("stairs", false),
			"fragment": fragment_id,
		})
	return result

static func _find_edge(a: String, b: String, edges: Array) -> Dictionary:
	for raw_edge: Variant in edges:
		var edge: Dictionary = raw_edge
		var ends: Array = edge.get("ends", [])
		if ends.size() == 2 and ((str(ends[0]) == a and str(ends[1]) == b) or (str(ends[0]) == b and str(ends[1]) == a)):
			return edge
	return {}

static func _single(rule_id: String, evidence_id: String, params: Dictionary) -> Dictionary:
	return {"valid": false, "violations": [{"rule_id": rule_id, "evidence_id": evidence_id, "params": params}], "resolved_state": {}}

static func _result(violations: Array) -> Dictionary:
	return {"valid": violations.is_empty(), "violations": violations, "resolved_state": {}}
