extends Node

const ContractLoader = preload("res://src/core/contract_loader.gd")
const ProgressionClass = preload("res://src/core/progression.gd")
const EvidenceRegistryClass = preload("res://src/core/evidence_registry.gd")
const CargoRules = preload("res://src/rules/cargo_rules.gd")

var puzzles_contract: Dictionary = {}
var evidence_contract: Dictionary = {}
var hints_contract: Dictionary = {}
var progression: RefCounted
var evidence_registry: RefCounted

var campaign: Dictionary = {}
var dirty := false

func _ready() -> void:
	if puzzles_contract.is_empty():
		var loaded := ContractLoader.load_and_validate()
		if loaded.get("ok", false):
			configure(loaded["data"])
			new_campaign()

func configure(data: Dictionary) -> void:
	puzzles_contract = (data.get("puzzles", {}) as Dictionary).duplicate(true)
	evidence_contract = (data.get("evidence", {}) as Dictionary).duplicate(true)
	hints_contract = (data.get("hints", {}) as Dictionary).duplicate(true)
	progression = ProgressionClass.new(puzzles_contract.get("progression", {}))
	evidence_registry = EvidenceRegistryClass.new(evidence_contract)

func new_campaign(campaign_id: String = "local-new") -> void:
	campaign = {
		"schema_version": 1,
		"content_version": str(puzzles_contract.get("design_version", "1.1")),
		"campaign_id": campaign_id,
		"completed": false,
		"solved": [],
		"seen_evidence": [],
		"hints": _initial_hints(),
		"location": {"view": "s02", "subview": "", "focus": ""},
		"puzzles": _initial_puzzles(),
		"narrative": {
			"active_scene": null,
			"segment": 0,
			"pending": ["n00"],
			"acknowledged": [],
		},
	}
	dirty = true

func _initial_hints() -> Dictionary:
	var result: Dictionary = {}
	for stage: Variant in hints_contract.keys():
		result[str(stage)] = 0
	return result

func _initial_puzzles() -> Dictionary:
	var p06_initial: Dictionary = puzzles_contract.get("p06", {}).get("initial", {}).duplicate(true)
	var initial := {
		"p00": {
			"latches": puzzles_contract.get("p00", {}).get("initial_latches", [false, false]).duplicate(),
			"opened": false,
		},
		"p01": {"order": puzzles_contract.get("p01", {}).get("initial", []).duplicate()},
		"p02": {"order": puzzles_contract.get("p02", {}).get("initial", []).duplicate()},
		"p03": {"bits": puzzles_contract.get("p03", {}).get("initial", []).duplicate()},
		"p04": {"turns": puzzles_contract.get("p04", {}).get("initial", []).duplicate()},
		"p05": {"slots": [null, null, null, null, null, null]},
		"p06": p06_initial,
		"p07": {"donor": null, "slots": [null, null, null, null, null, null], "part_a_solved": false},
	}

	for i in range(8,18):
		var id := "p%02d" % i
		initial[id] = puzzles_contract[id].initial.duplicate(true)
	return initial

func can_enter(stage_id: String) -> bool:
	return stage_id in campaign.get("solved", []) or (progression != null and progression.can_enter(stage_id, campaign.get("solved", [])))

func available_evidence() -> Array:
	if evidence_registry == null:
		return []
	return evidence_registry.available_evidence(campaign.get("solved", []))

func mark_evidence_seen(evidence_id: String) -> Dictionary:
	if evidence_id not in available_evidence():
		return {"ok": false, "error": "evidence_not_available"}
	var seen: Array = campaign.get("seen_evidence", [])
	if evidence_id not in seen:
		seen.append(evidence_id)
		dirty = true
	return {"ok": true}

func set_hint_level(puzzle_id: String, level: int) -> Dictionary:
	if not campaign.get("hints", {}).has(puzzle_id):
		return {"ok": false, "error": "unknown_hint_stage"}
	var clamped := clampi(level, 0, 3)
	var current := int(campaign["hints"][puzzle_id])
	if clamped < current:
		return {"ok": false, "error": "hint_level_monotone"}
	campaign["hints"][puzzle_id] = clamped
	dirty = dirty or clamped != current
	return {"ok": true}

func swap_order(puzzle_id: String, a: int, b: int) -> Dictionary:
	if puzzle_id in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	if puzzle_id not in ["p01", "p02"]:
		return {"ok": false, "error": "unsupported_swap"}
	var order: Array = campaign["puzzles"][puzzle_id]["order"]
	if a < 0 or b < 0 or a >= order.size() or b >= order.size():
		return {"ok": false, "error": "index_out_of_range"}
	if a == b:
		return {"ok": true, "changed": false}
	var before := order.duplicate()
	var tmp: Variant = order[a]
	order[a] = order[b]
	order[b] = tmp
	dirty = true
	return {"ok": true, "changed": true, "before": before}

func flip_tile(index: int) -> Dictionary:
	if "p03" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	var bits: Array = campaign["puzzles"]["p03"]["bits"]
	if index < 0 or index >= bits.size():
		return {"ok": false, "error": "index_out_of_range"}
	bits[index] = 1 - int(bits[index])
	dirty = true
	return {"ok": true}

func rotate_mask(index: int, delta: int) -> Dictionary:
	if "p04" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	var turns: Array = campaign["puzzles"]["p04"]["turns"]
	if index < 0 or index >= turns.size():
		return {"ok": false, "error": "index_out_of_range"}
	turns[index] = posmod(int(turns[index]) + delta, 4)
	dirty = true
	return {"ok": true}

func place_cargo(item: String, slot_index: int) -> Dictionary:
	if "p05" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	var p05: Dictionary = campaign["puzzles"]["p05"]
	var slots: Array = p05["slots"]
	if not puzzles_contract["p05"]["weights"].has(item):
		return {"ok": false, "error": "unknown_cargo"}
	if slot_index < -1 or slot_index >= slots.size():
		return {"ok": false, "error": "index_out_of_range"}
	var source := slots.find(item)
	if slot_index == -1:
		if source >= 0:
			slots[source] = null
			dirty = true
		return {"ok": true}
	if not CargoRules.can_place(item, slot_index, puzzles_contract["p05"]):
		return {"ok": false, "error": "gauge_rejected"}
	var displaced: Variant = slots[slot_index]
	if displaced != null and source >= 0 and not CargoRules.can_place(str(displaced), source, puzzles_contract["p05"]):
		return {"ok": false, "error": "atomic_exchange_rejected"}
	var next := slots.duplicate()
	if source >= 0:
		next[source] = displaced
	next[slot_index] = item
	p05["slots"] = next
	dirty = true
	return {"ok": true}

func set_water_level(level: int) -> Dictionary:
	if "p06" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	if level not in puzzles_contract["p06"]["water_levels"]:
		return {"ok": false, "error": "invalid_water_level"}
	campaign["puzzles"]["p06"]["water_level"] = level
	dirty = true
	return {"ok": true}

func place_fragment(fragment_id: String, gap_id: Variant) -> Dictionary:
	if "p06" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	var fragments: Dictionary = puzzles_contract["p06"]["fragments"]
	if not fragments.has(fragment_id):
		return {"ok": false, "error": "unknown_fragment"}
	if gap_id != null and str(gap_id) not in fragments[fragment_id]["destinations"]:
		return {"ok": false, "error": "incompatible_gap"}
	campaign["puzzles"]["p06"]["fragments"][fragment_id] = gap_id
	dirty = true
	return {"ok": true}

func set_route(group_id: String, route: Array) -> Dictionary:
	if "p06" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	if not puzzles_contract["p06"]["groups"].has(group_id):
		return {"ok": false, "error": "unknown_group"}
	campaign["puzzles"]["p06"]["routes"][group_id] = route.duplicate()
	dirty = true
	return {"ok": true}

func set_p07_donor(donor_id: Variant) -> Dictionary:
	if "p07" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	if donor_id != null and not puzzles_contract["p07"]["donors"].has(str(donor_id)):
		return {"ok": false, "error": "unknown_donor"}
	campaign["puzzles"]["p07"]["donor"] = donor_id
	dirty = true
	return {"ok": true}

func place_p07_action(action: String, slot_index: int) -> Dictionary:
	if "p07" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	var slots: Array = campaign["puzzles"]["p07"]["slots"]
	if action not in puzzles_contract["p07"]["actions"]:
		return {"ok": false, "error": "unknown_action"}
	if slot_index < -1 or slot_index >= slots.size():
		return {"ok": false, "error": "index_out_of_range"}
	var source := slots.find(action)
	if slot_index == -1:
		if source >= 0:
			slots[source] = null
			dirty = true
		return {"ok": true}
	var next := slots.duplicate()
	var displaced: Variant = next[slot_index]
	if source >= 0:
		next[source] = displaced
	next[slot_index] = action
	campaign["puzzles"]["p07"]["slots"] = next
	dirty = true
	return {"ok": true}

func resolve_puzzle(puzzle_id: String, resolved_state: Dictionary = {}) -> Dictionary:
	if puzzle_id not in puzzles_contract.get("progression", {}):
		return {"ok": false, "error": "unknown_stage"}
	if puzzle_id == "ending":
		return {"ok": false, "error": "ending_is_narrative"}
	if puzzle_id in ["p08", "p09", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17"]:
		if not preload("res://src/rules/expansion_rules.gd").validate(puzzles_contract[puzzle_id],campaign.puzzles[puzzle_id]).valid:
			return {"ok":false,"error":"invalid_solution"}
	var applied: Dictionary = progression.apply_solved(puzzle_id, campaign.get("solved", []))
	if not applied.get("ok", false):
		return applied
	if not applied.get("changed", false):
		return {"ok": true, "changed": false}
	if not resolved_state.is_empty() and campaign["puzzles"].has(puzzle_id):
		for key: Variant in resolved_state.keys():
			campaign["puzzles"][puzzle_id][key] = resolved_state[key]
	campaign["solved"] = applied["solved"]
	_queue_resolution_narrative(puzzle_id)
	dirty = true
	return {
		"ok": true,
		"changed": true,
		"available_evidence": available_evidence(),
		"pending_narrative": campaign["narrative"]["pending"].duplicate(),
	}

func queue_narrative(scene_id: String) -> void:
	var narrative: Dictionary = campaign["narrative"]
	if scene_id in narrative["acknowledged"] or scene_id in narrative["pending"] or narrative.get("active_scene") == scene_id:
		return
	narrative["pending"].append(scene_id)
	dirty = true

func begin_next_narrative() -> Variant:
	var narrative: Dictionary = campaign["narrative"]
	if narrative.get("active_scene") != null:
		return narrative["active_scene"]
	if narrative["pending"].is_empty():
		return null
	narrative["active_scene"] = narrative["pending"].pop_front()
	narrative["segment"] = 0
	dirty = true
	return narrative["active_scene"]

func acknowledge_narrative(scene_id: String) -> Dictionary:
	var narrative: Dictionary = campaign["narrative"]
	if narrative.get("active_scene") != scene_id and scene_id not in narrative["pending"]:
		if scene_id in narrative["acknowledged"]:
			return {"ok": true, "changed": false}
		return {"ok": false, "error": "scene_not_pending"}
	narrative["pending"].erase(scene_id)
	if scene_id not in narrative["acknowledged"]:
		narrative["acknowledged"].append(scene_id)
	narrative["active_scene"] = null
	narrative["segment"] = 0
	if scene_id == "n11":
		campaign["completed"] = true
	dirty = true
	return {"ok": true, "changed": true}

func _queue_resolution_narrative(puzzle_id: String) -> void:
	if puzzle_id in ["p08", "p09", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17"]:
		queue_narrative("n_"+puzzle_id)
	var scene_by_puzzle := {
		"p01": "n01",
		"p02": "n02",
		"p03": "n03",
		"p04": "n04",
		"p05": "n06",
		"p06": "n07",
	}
	if scene_by_puzzle.has(puzzle_id):
		queue_narrative(scene_by_puzzle[puzzle_id])
	if puzzle_id in ["p03", "p04"] and "p03" in campaign["solved"] and "p04" in campaign["solved"]:
		queue_narrative("n05")

func reset_unsolved_puzzle(puzzle_id: String) -> Dictionary:
	if puzzle_id in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	var initial := _initial_puzzles()
	if not initial.has(puzzle_id):
		return {"ok": false, "error": "unknown_puzzle"}
	campaign["puzzles"][puzzle_id] = initial[puzzle_id].duplicate(true)
	dirty = true
	return {"ok": true}

func toggle_latch(index: int) -> Dictionary:
	if "p00" in campaign.get("solved", []):
		return {"ok": false, "error": "resolved_puzzle_read_only"}
	var latches: Array = campaign["puzzles"]["p00"]["latches"]
	if index < 0 or index >= latches.size():
		return {"ok": false, "error": "index_out_of_range"}
	latches[index] = not bool(latches[index])
	dirty = true
	return {"ok": true, "latches": latches.duplicate()}

func open_box() -> Dictionary:
	if "p00" in campaign.get("solved", []):
		return {"ok": true, "changed": false}
	var latches: Array = campaign["puzzles"]["p00"]["latches"]
	if latches.size() != 2 or not bool(latches[0]) or not bool(latches[1]):
		return {"ok": false, "error": "latch_closed"}
	campaign["puzzles"]["p00"]["opened"] = true
	return resolve_puzzle("p00", {"latches": latches.duplicate(), "opened": true})
