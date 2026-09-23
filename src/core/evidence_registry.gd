class_name EvidenceRegistry
extends RefCounted

var contract: Dictionary
var by_id: Dictionary = {}

func _init(evidence_contract: Dictionary) -> void:
	contract = evidence_contract.duplicate(true)
	for raw_item: Variant in contract.get("items", []):
		var item: Dictionary = raw_item
		by_id[str(item.get("id", ""))] = item

func available_evidence(solved: Array) -> Array:
	var result: Array = []
	for raw_item: Variant in contract.get("items", []):
		var item: Dictionary = raw_item
		var allowed := true
		for raw_req: Variant in item.get("requires_solved", []):
			if str(raw_req) not in solved:
				allowed = false
				break
		if allowed:
			result.append(str(item.get("id", "")))
	return result

func required_for(stage_id: String) -> Array:
	return contract.get("required_by_stage", {}).get(stage_id, []).duplicate()

func is_available(evidence_id: String, solved: Array) -> bool:
	return evidence_id in available_evidence(solved)
