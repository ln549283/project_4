class_name Progression
extends RefCounted

var graph: Dictionary

func _init(progression_graph: Dictionary) -> void:
	graph = progression_graph.duplicate(true)

func can_enter(stage_id: String, solved: Array) -> bool:
	if not graph.has(stage_id):
		return false
	for raw_req: Variant in graph[stage_id]:
		if str(raw_req) not in solved:
			return false
	return true

func apply_solved(stage_id: String, solved: Array) -> Dictionary:
	if not graph.has(stage_id):
		return {"ok": false, "error": "unknown_stage", "solved": solved.duplicate()}
	if stage_id in solved:
		return {"ok": true, "changed": false, "solved": solved.duplicate()}
	if not can_enter(stage_id, solved):
		return {"ok": false, "error": "prerequisites_not_met", "solved": solved.duplicate()}
	var next := solved.duplicate()
	next.append(stage_id)
	return {"ok": true, "changed": true, "solved": next}

func available_stages(solved: Array) -> Array:
	var result: Array = []
	for raw_stage: Variant in graph.keys():
		var stage := str(raw_stage)
		if stage not in solved and can_enter(stage, solved):
			result.append(stage)
	return result
