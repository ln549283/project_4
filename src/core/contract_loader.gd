class_name ContractLoader
extends RefCounted

const PUZZLES_PATH := "res://design/puzzles.json"
const EVIDENCE_PATH := "res://design/evidence.json"
const HINTS_PATH := "res://design/hints_fr.json"
const DESIGN_VERSION := "1.1"
const STAGES := ["p00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "ending"]
const PUZZLES := ["p00", "p01", "p02", "p03", "p04", "p05", "p06", "p07"]
const HINT_STAGES := ["p01", "p02", "p03", "p04", "p05", "p06", "p07"]

static func load_and_validate() -> Dictionary:
	var errors: Array[String] = []
	var puzzles := _load_json(PUZZLES_PATH, errors)
	var evidence := _load_json(EVIDENCE_PATH, errors)
	var hints := _load_json(HINTS_PATH, errors)
	if not errors.is_empty():
		return {"ok": false, "errors": errors, "data": {}}
	var validation := validate_contracts(puzzles, evidence, hints)
	validation["data"] = {
		"puzzles": puzzles,
		"evidence": evidence,
		"hints": hints,
	}
	return validation

static func validate_contracts(puzzles: Dictionary, evidence: Dictionary, hints: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	_validate_versions(puzzles, evidence, errors)
	_validate_progression(puzzles, errors)
	_validate_puzzle_sections(puzzles, errors)
	_validate_evidence(evidence, errors)
	_validate_hints(hints, errors)
	return {"ok": errors.is_empty(), "errors": errors}

static func _load_json(path: String, errors: Array[String]) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("missing_contract:%s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("unreadable_contract:%s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		errors.append("invalid_json_object:%s" % path)
		return {}
	return parsed as Dictionary

static func _validate_versions(puzzles: Dictionary, evidence: Dictionary, errors: Array[String]) -> void:
	if puzzles.get("design_version", "") != DESIGN_VERSION:
		errors.append("puzzles.design_version_expected_%s" % DESIGN_VERSION)
	if evidence.get("design_version", "") != DESIGN_VERSION:
		errors.append("evidence.design_version_expected_%s" % DESIGN_VERSION)

static func _validate_progression(puzzles: Dictionary, errors: Array[String]) -> void:
	var progression: Variant = puzzles.get("progression")
	if typeof(progression) != TYPE_DICTIONARY:
		errors.append("progression_missing_or_not_object")
		return
	var graph: Dictionary = progression
	for stage in STAGES:
		if not graph.has(stage):
			errors.append("progression_missing_stage:%s" % stage)
	for stage: Variant in graph.keys():
		var stage_id := str(stage)
		if stage_id not in STAGES:
			errors.append("progression_unknown_stage:%s" % stage_id)
			continue
		var reqs: Variant = graph[stage]
		if typeof(reqs) != TYPE_ARRAY:
			errors.append("progression_prerequisites_not_array:%s" % stage_id)
			continue
		var seen: Dictionary = {}
		for req: Variant in reqs:
			var req_id := str(req)
			if req_id not in STAGES:
				errors.append("progression_unknown_prerequisite:%s->%s" % [stage_id, req_id])
			if req_id == stage_id:
				errors.append("progression_self_dependency:%s" % stage_id)
			if seen.has(req_id):
				errors.append("progression_duplicate_prerequisite:%s->%s" % [stage_id, req_id])
			seen[req_id] = true
	_validate_acyclic(graph, errors)

static func _validate_acyclic(graph: Dictionary, errors: Array[String]) -> void:
	var resolved: Dictionary = {}
	var unresolved: Dictionary = {}
	for stage in STAGES:
		if graph.has(stage):
			unresolved[stage] = true
	while not unresolved.is_empty():
		var progressed := false
		var pending: Array = unresolved.keys()
		for stage: Variant in pending:
			var stage_id := str(stage)
			var reqs: Variant = graph.get(stage_id, [])
			if typeof(reqs) != TYPE_ARRAY:
				continue
			var ready := true
			for req: Variant in reqs:
				if not resolved.has(str(req)):
					ready = false
					break
			if ready:
				resolved[stage_id] = true
				unresolved.erase(stage_id)
				progressed = true
		if not progressed:
			errors.append("progression_cycle_or_unreachable:%s" % ",".join(unresolved.keys()))
			return

static func _validate_puzzle_sections(puzzles: Dictionary, errors: Array[String]) -> void:
	for puzzle_id in PUZZLES:
		if not puzzles.has(puzzle_id) or typeof(puzzles[puzzle_id]) != TYPE_DICTIONARY:
			errors.append("missing_puzzle_contract:%s" % puzzle_id)

static func _validate_evidence(evidence: Dictionary, errors: Array[String]) -> void:
	var items: Variant = evidence.get("items")
	if typeof(items) != TYPE_ARRAY:
		errors.append("evidence.items_missing_or_not_array")
		return
	var ids: Dictionary = {}
	for raw_item: Variant in items:
		if typeof(raw_item) != TYPE_DICTIONARY:
			errors.append("evidence.item_not_object")
			continue
		var item: Dictionary = raw_item
		var evidence_id := str(item.get("id", ""))
		if evidence_id.is_empty():
			errors.append("evidence.empty_id")
			continue
		if ids.has(evidence_id):
			errors.append("evidence.duplicate_id:%s" % evidence_id)
		ids[evidence_id] = true
		var reqs: Variant = item.get("requires_solved", [])
		if typeof(reqs) != TYPE_ARRAY:
			errors.append("evidence.requires_solved_not_array:%s" % evidence_id)
			continue
		for req: Variant in reqs:
			var req_id := str(req)
			if req_id not in PUZZLES:
				errors.append("evidence.unknown_prerequisite:%s->%s" % [evidence_id, req_id])
	var required: Variant = evidence.get("required_by_stage")
	if typeof(required) != TYPE_DICTIONARY:
		errors.append("evidence.required_by_stage_missing_or_not_object")
		return
	for stage: Variant in required.keys():
		var stage_id := str(stage)
		if stage_id not in STAGES:
			errors.append("evidence.required_unknown_stage:%s" % stage_id)
		var stage_items: Variant = required[stage]
		if typeof(stage_items) != TYPE_ARRAY:
			errors.append("evidence.required_not_array:%s" % stage_id)
			continue
		for evidence_ref: Variant in stage_items:
			var evidence_ref_id := str(evidence_ref)
			if not ids.has(evidence_ref_id):
				errors.append("evidence.required_unknown_id:%s->%s" % [stage_id, evidence_ref_id])

static func _validate_hints(hints: Dictionary, errors: Array[String]) -> void:
	var total := 0
	for stage in HINT_STAGES:
		if not hints.has(stage):
			errors.append("hints.missing_stage:%s" % stage)
			continue
		var ladder: Variant = hints[stage]
		if typeof(ladder) != TYPE_ARRAY:
			errors.append("hints.stage_not_array:%s" % stage)
			continue
		if ladder.size() != 3:
			errors.append("hints.expected_three:%s" % stage)
		for hint: Variant in ladder:
			if typeof(hint) != TYPE_STRING or str(hint).strip_edges().is_empty():
				errors.append("hints.invalid_text:%s" % stage)
			total += 1
	for stage: Variant in hints.keys():
		if str(stage) not in HINT_STAGES:
			errors.append("hints.unknown_stage:%s" % str(stage))
	if total != 21:
		errors.append("hints.expected_21_got_%d" % total)
