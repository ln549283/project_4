class_name CargoRules
extends RefCounted

static func validate(slots: Array, contract: Dictionary) -> Dictionary:
	var violations: Array = []
	var positions: Array = contract.get("positions", [])
	var weights: Dictionary = contract.get("weights", {})
	if slots.size() != positions.size():
		violations.append({"rule_id": "p05_all_slots", "evidence_id": "evidence_cargo", "params": {}})
		return _result(violations)

	var seen: Dictionary = {}
	for raw_item: Variant in slots:
		if raw_item == null:
			violations.append({"rule_id": "p05_missing_cargo", "evidence_id": "evidence_cargo", "params": {}})
			return _result(violations)
		var item := str(raw_item)
		if not weights.has(item):
			violations.append({"rule_id": "p05_unknown_cargo", "evidence_id": "evidence_cargo", "params": {"item": item}})
			return _result(violations)
		if seen.has(item):
			violations.append({"rule_id": "p05_unique_cargo", "evidence_id": "evidence_cargo", "params": {"item": item}})
			return _result(violations)
		seen[item] = true
	if seen.size() != weights.size():
		violations.append({"rule_id": "p05_all_cargo", "evidence_id": "evidence_cargo", "params": {}})
		return _result(violations)

	for raw_item: Variant in contract.get("central_only", []):
		var item := str(raw_item)
		var index := slots.find(item)
		if index < 0 or abs(int(positions[index])) != 1:
			violations.append({"rule_id": "p05_central_gauge", "evidence_id": "evidence_cargo", "params": {"item": item}})
			return _result(violations)

	var moment := calculate_moment(slots, positions, weights)
	if moment != 0:
		violations.append({"rule_id": "p05_unbalanced", "evidence_id": "evidence_cargo", "params": {"moment": moment}})
	return {"valid": violations.is_empty(), "violations": violations, "resolved_state": {"moment": moment}}

static func calculate_moment(slots: Array, positions: Array, weights: Dictionary) -> int:
	var moment := 0
	for i in range(min(slots.size(), positions.size())):
		if slots[i] != null and weights.has(str(slots[i])):
			moment += int(positions[i]) * int(weights[str(slots[i])])
	return moment

static func can_place(item: String, slot_index: int, contract: Dictionary) -> bool:
	var positions: Array = contract.get("positions", [])
	if slot_index < 0 or slot_index >= positions.size():
		return false
	if item in contract.get("central_only", []):
		return abs(int(positions[slot_index])) == 1
	return contract.get("weights", {}).has(item)

static func _result(violations: Array) -> Dictionary:
	return {"valid": violations.is_empty(), "violations": violations, "resolved_state": {}}
