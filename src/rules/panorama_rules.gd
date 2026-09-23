class_name PanoramaRules
extends RefCounted

static func validate(order: Array, contract: Dictionary) -> Dictionary:
	var violations: Array = []
	var pieces: Dictionary = contract.get("pieces", {})
	if order.size() != pieces.size():
		violations.append({"rule_id": "p01_complete", "evidence_id": "evidence_map", "params": {}})
		return _result(violations)

	var seen: Dictionary = {}
	var edge := str(contract.get("left_anchor", ""))
	for raw_id: Variant in order:
		var piece_id := str(raw_id)
		if not pieces.has(piece_id):
			violations.append({"rule_id": "p01_unknown_piece", "evidence_id": "evidence_map", "params": {"piece": piece_id}})
			continue
		if seen.has(piece_id):
			violations.append({"rule_id": "p01_unique_piece", "evidence_id": "evidence_map", "params": {"piece": piece_id}})
			continue
		seen[piece_id] = true
		var borders: Array = pieces[piece_id]
		if borders.size() != 2 or str(borders[0]) != edge:
			violations.append({"rule_id": "p01_broken_seam", "evidence_id": "evidence_map", "params": {"piece": piece_id, "expected_left": edge}})
			return _result(violations)
		edge = str(borders[1])

	if seen.size() != pieces.size():
		violations.append({"rule_id": "p01_complete", "evidence_id": "evidence_map", "params": {}})
	elif edge != str(contract.get("right_anchor", "")):
		violations.append({"rule_id": "p01_right_anchor", "evidence_id": "evidence_map", "params": {"edge": edge}})
	return _result(violations)

static func _result(violations: Array) -> Dictionary:
	return {"valid": violations.is_empty(), "violations": violations}
