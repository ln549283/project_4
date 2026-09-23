class_name MasksRules
extends RefCounted

static func validate(turns: Array, contract: Dictionary) -> Dictionary:
	var violations: Array = []
	var masks: Array = contract.get("masks", [])
	if turns.size() != masks.size():
		violations.append({"rule_id": "p04_three_layers", "evidence_id": "evidence_projection", "params": {}})
		return _result(violations)
	var rotated: Array = []
	for i in range(masks.size()):
		rotated.append(rotate_mask(masks[i], int(turns[i])))
	var union_mask := union_masks(rotated)
	if union_mask != contract.get("target", []):
		violations.append({"rule_id": "p04_silhouette_mismatch", "evidence_id": "evidence_projection", "params": {}})
	return {"valid": violations.is_empty(), "violations": violations, "resolved_state": {"union": union_mask}}

static func rotate_mask(raw_mask: Array, turns: int) -> Array:
	var mask: Array = raw_mask.duplicate()
	var normalized := posmod(turns, 4)
	for _step in range(normalized):
		var size := mask.size()
		var next: Array = []
		for y in range(size):
			var row := ""
			for x in range(size):
				var source_row := str(mask[size - 1 - x])
				row += source_row.substr(y, 1)
			next.append(row)
		mask = next
	return mask

static func union_masks(masks: Array) -> Array:
	if masks.is_empty():
		return []
	var size := (masks[0] as Array).size()
	var result: Array = []
	for y in range(size):
		var row := ""
		for x in range(size):
			var filled := false
			for raw_mask: Variant in masks:
				var mask: Array = raw_mask
				if str(mask[y]).substr(x, 1) == "1":
					filled = true
					break
			row += "1" if filled else "0"
		result.append(row)
	return result

static func _result(violations: Array) -> Dictionary:
	return {"valid": violations.is_empty(), "violations": violations, "resolved_state": {}}
