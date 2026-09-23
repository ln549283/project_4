class_name SequenceRules
extends RefCounted

static func validate_donor(donor_id: String, contract: Dictionary) -> Dictionary:
	var donors: Dictionary = contract.get("donors", {})
	if not donors.has(donor_id):
		return _single("p07_unknown_donor", "evidence_photo_f2", {"donor": donor_id})
	var donor: Dictionary = donors[donor_id]
	var requirements: Dictionary = contract.get("requirements", {})
	if int(donor.get("span", -1)) != int(requirements.get("span", -2)):
		return _single("p07_wrong_span", "evidence_tide", {"donor": donor_id})
	if int(donor.get("width", -1)) < int(requirements.get("min_width", 0)):
		return _single("p07_too_narrow", "evidence_photo_f2", {"donor": donor_id})
	if bool(donor.get("flat", false)) != bool(requirements.get("flat", true)):
		return _single("p07_profile_mismatch", "evidence_photo_f2", {"donor": donor_id})
	if bool(donor.get("paired_fasteners", false)) != bool(requirements.get("paired_fasteners", true)):
		return _single("p07_fasteners_mismatch", "evidence_photo_f2", {"donor": donor_id})
	return {"valid": true, "violations": [], "resolved_state": {"donor": donor_id}}

static func validate_sequence(sequence: Array, contract: Dictionary) -> Dictionary:
	var actions: Array = contract.get("actions", [])
	if sequence.size() != int(contract.get("slots", actions.size())):
		return _single("p07_incomplete_sequence", "evidence_tide", {})
	var seen: Dictionary = {}
	for raw_action: Variant in sequence:
		var action := str(raw_action)
		if action not in actions:
			return _single("p07_unknown_action", "evidence_tide", {"action": action})
		if seen.has(action):
			return _single("p07_duplicate_action", "evidence_tide", {"action": action})
		seen[action] = true
	if seen.size() != actions.size():
		return _single("p07_missing_action", "evidence_tide", {})

	var windows: Dictionary = contract.get("windows", {})
	for index in range(sequence.size()):
		var action := str(sequence[index])
		var window: Array = windows.get(action, [])
		if window.size() != 2 or index < int(window[0]) or index > int(window[1]):
			return _single("p07_window_violation", "evidence_tide", {"action": action, "phase": index})

	var positions: Dictionary = {}
	for i in range(sequence.size()):
		positions[str(sequence[i])] = i
	for raw_pair: Variant in contract.get("before", []):
		var pair: Array = raw_pair
		if pair.size() == 2 and int(positions[str(pair[0])]) >= int(positions[str(pair[1])]):
			return _single("p07_before_violation", "evidence_tide", {"before": pair[0], "after": pair[1]})
	return {"valid": true, "violations": [], "resolved_state": {"sequence": sequence.duplicate()}}

static func validate(donor_id: String, sequence: Array, contract: Dictionary) -> Dictionary:
	var donor_result := validate_donor(donor_id, contract)
	if not donor_result.get("valid", false):
		return donor_result
	return validate_sequence(sequence, contract)

static func _single(rule_id: String, evidence_id: String, params: Dictionary) -> Dictionary:
	return {"valid": false, "violations": [{"rule_id": rule_id, "evidence_id": evidence_id, "params": params}], "resolved_state": {}}
