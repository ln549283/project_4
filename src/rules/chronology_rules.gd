class_name ChronologyRules
extends RefCounted

const DETAIL_ORDER := ["awning", "pane", "sign", "chimney"]

static func validate(order: Array, contract: Dictionary) -> Dictionary:
	var violations: Array = []
	var observations: Dictionary = contract.get("observations", {})
	if order.size() != observations.size():
		violations.append({"rule_id": "p02_complete", "evidence_id": "evidence_photo_note", "params": {}})
		return _result(violations)

	var seen_photos: Dictionary = {}
	var last: Dictionary = {}
	for raw_id: Variant in order:
		var photo_id := str(raw_id)
		if not observations.has(photo_id):
			violations.append({"rule_id": "p02_unknown_photo", "evidence_id": "evidence_photo_note", "params": {"photo": photo_id}})
			return _result(violations)
		if seen_photos.has(photo_id):
			violations.append({"rule_id": "p02_unique_photo", "evidence_id": "evidence_photo_note", "params": {"photo": photo_id}})
			return _result(violations)
		seen_photos[photo_id] = true
		var current: Dictionary = observations[photo_id]
		for detail in DETAIL_ORDER:
			if not current.has(detail):
				continue
			var state := int(current[detail])
			if last.has(detail) and state < int(last[detail]):
				violations.append({
					"rule_id": "p02_damage_reversed",
					"evidence_id": "evidence_photo_note",
					"params": {"detail": detail, "photo": photo_id},
				})
				return _result(violations)
			last[detail] = state
	return _result(violations)

static func _result(violations: Array) -> Dictionary:
	return {"valid": violations.is_empty(), "violations": violations}
