class_name SaveService
extends RefCounted

const SCHEMA_VERSION := 1
const CONTENT_VERSION := "1.1"
const PUZZLE_IDS := ["p00", "p01", "p02", "p03", "p04", "p05", "p06", "p07"]
const NARRATIVE_IDS := ["n00", "n01", "n02", "n03", "n04", "n05", "n06", "n07", "n08", "n09", "n10", "n11"]

var root_path: String
var puzzles_contract: Dictionary

func _init(contract: Dictionary, root: String = "user://") -> void:
	puzzles_contract = contract.duplicate(true)
	root_path = root.trim_suffix("/")
	_ensure_root()

func load_campaign() -> Dictionary:
	var a := _read_slot(_slot_path("a"))
	var b := _read_slot(_slot_path("b"))
	var slots := [a, b]
	for info: Dictionary in slots:
		if info.get("status") == "future":
			return {
				"status": "future_version",
				"path": info.get("path"),
				"generation": info.get("generation", -1),
			}
	var valid: Array = []
	var invalid_paths: Array = []
	for info: Dictionary in slots:
		if info.get("status") == "valid":
			valid.append(info)
		elif info.get("status") == "invalid":
			invalid_paths.append(info.get("path"))
	if valid.is_empty():
		if invalid_paths.is_empty():
			return {"status": "new", "snapshot": null, "generation": 0}
		return {"status": "unreadable", "snapshot": null, "invalid_paths": invalid_paths}
	valid.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return int(x["generation"]) > int(y["generation"]))
	var selected: Dictionary = valid[0]
	return {
		"status": "recovered" if not invalid_paths.is_empty() else "ok",
		"snapshot": selected["snapshot"].duplicate(true),
		"generation": selected["generation"],
		"path": selected["path"],
		"invalid_paths": invalid_paths,
	}

func save_campaign(snapshot: Dictionary, fail_phase: String = "") -> Dictionary:
	var a := _read_slot(_slot_path("a"))
	var b := _read_slot(_slot_path("b"))
	for info: Dictionary in [a, b]:
		if info.get("status") == "future":
			return {"ok": false, "error": "future_version_present"}
	var valid: Array = []
	for info: Dictionary in [a, b]:
		if info.get("status") == "valid":
			valid.append(info)
	var generation := 1
	for info: Dictionary in valid:
		generation = maxi(generation, int(info["generation"]) + 1)
	var target := _choose_target(a, b)
	if target.get("status") == "invalid":
		_preserve_diagnostic(str(target["path"]))
	if fail_phase == "disk_refused":
		return {"ok": false, "error": "write_refused", "generation": generation}

	var payload: Dictionary = snapshot.duplicate(true)
	payload["schema_version"] = SCHEMA_VERSION
	payload["content_version"] = CONTENT_VERSION
	payload["generation"] = generation
	payload["saved_at_utc"] = Time.get_datetime_string_from_system(true, true)
	var envelope := make_envelope(payload)
	var target_path := str(target["path"])
	var tmp_path := target_path + ".tmp"
	var write_result := _write_text(tmp_path, JSON.stringify(envelope))
	if not write_result:
		return {"ok": false, "error": "tmp_write_failed", "generation": generation}
	if fail_phase == "after_tmp_write":
		return {"ok": false, "error": "simulated_after_tmp_write", "generation": generation}

	var verify_tmp := _read_slot(tmp_path)
	if verify_tmp.get("status") != "valid" or int(verify_tmp.get("generation", -1)) != generation:
		return {"ok": false, "error": "tmp_verification_failed", "generation": generation}
	if fail_phase == "after_tmp_verify":
		return {"ok": false, "error": "simulated_after_tmp_verify", "generation": generation}

	var target_abs := ProjectSettings.globalize_path(target_path)
	if FileAccess.file_exists(target_path):
		if DirAccess.remove_absolute(target_abs) != OK:
			return {"ok": false, "error": "target_remove_failed", "generation": generation}
	if fail_phase == "after_target_remove":
		return {"ok": false, "error": "simulated_after_target_remove", "generation": generation}

	var tmp_abs := ProjectSettings.globalize_path(tmp_path)
	if DirAccess.rename_absolute(tmp_abs, target_abs) != OK:
		return {"ok": false, "error": "replace_failed", "generation": generation}
	if fail_phase == "after_replace":
		return {"ok": false, "error": "simulated_after_replace", "generation": generation}
	return {"ok": true, "generation": generation, "path": target_path, "snapshot": payload}

func backup_for_restart() -> Dictionary:
	var loaded := load_campaign()
	if loaded.get("status") not in ["ok", "recovered"]:
		return {"ok": false, "error": "no_valid_campaign"}
	var source_path := str(loaded.get("path", ""))
	if source_path.is_empty():
		return {"ok": false, "error": "no_valid_campaign"}
	var raw := FileAccess.get_file_as_string(source_path)
	var backup := _path("campaign_restart_backup.json")
	if not _write_text(backup + ".tmp", raw):
		return {"ok": false, "error": "backup_write_failed"}
	var backup_abs := ProjectSettings.globalize_path(backup)
	if FileAccess.file_exists(backup):
		DirAccess.remove_absolute(backup_abs)
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(backup + ".tmp"), backup_abs) != OK:
		return {"ok": false, "error": "backup_replace_failed"}
	return {"ok": true, "path": backup}

func save_settings(settings: Dictionary) -> Dictionary:
	var path := _path("settings.json")
	var backup := _path("settings_backup.json")
	var tmp := path + ".tmp"
	if not _write_text(tmp, JSON.stringify(settings)):
		return {"ok": false, "error": "settings_write_failed"}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(tmp))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "settings_verify_failed"}
	if FileAccess.file_exists(path):
		_write_text(backup, FileAccess.get_file_as_string(path))
	var path_abs := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path_abs)
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), path_abs) != OK:
		return {"ok": false, "error": "settings_replace_failed"}
	return {"ok": true}

func load_settings(defaults: Dictionary) -> Dictionary:
	for path in [_path("settings.json"), _path("settings_backup.json")]:
		if not FileAccess.file_exists(path):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(parsed) == TYPE_DICTIONARY:
			var merged := defaults.duplicate(true)
			for key: Variant in (parsed as Dictionary).keys():
				merged[key] = parsed[key]
			return {"ok": true, "settings": merged, "recovered": path.ends_with("settings_backup.json")}
	return {"ok": true, "settings": defaults.duplicate(true), "recovered": false}

func make_envelope(snapshot: Dictionary) -> Dictionary:
	var payload_utf8 := JSON.stringify(snapshot)
	return {
		"generation": int(snapshot.get("generation", 0)),
		"payload_utf8": payload_utf8,
		"sha256": _sha256(payload_utf8),
	}

func write_envelope_for_test(slot_name: String, snapshot: Dictionary) -> bool:
	var envelope := make_envelope(snapshot)
	return _write_text(_slot_path(slot_name), JSON.stringify(envelope))

func _read_slot(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"status": "missing", "path": path, "generation": -1}
	var raw := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"status": "invalid", "path": path, "reason": "envelope_json", "generation": -1}
	var envelope: Dictionary = parsed
	if not envelope.has("generation") or not envelope.has("payload_utf8") or not envelope.has("sha256"):
		return {"status": "invalid", "path": path, "reason": "envelope_shape", "generation": -1}
	var payload_utf8 := str(envelope["payload_utf8"])
	if _sha256(payload_utf8) != str(envelope["sha256"]):
		return {"status": "invalid", "path": path, "reason": "hash", "generation": int(envelope.get("generation", -1))}
	var payload_parsed: Variant = JSON.parse_string(payload_utf8)
	if typeof(payload_parsed) != TYPE_DICTIONARY:
		return {"status": "invalid", "path": path, "reason": "payload_json", "generation": int(envelope.get("generation", -1))}
	var snapshot: Dictionary = payload_parsed
	if int(snapshot.get("generation", -2)) != int(envelope.get("generation", -1)):
		return {"status": "invalid", "path": path, "reason": "generation_mismatch", "generation": int(envelope.get("generation", -1))}
	var schema := int(snapshot.get("schema_version", -1))
	var content := str(snapshot.get("content_version", ""))
	if schema > SCHEMA_VERSION or (schema == SCHEMA_VERSION and content != CONTENT_VERSION):
		return {"status": "future", "path": path, "generation": int(envelope["generation"])}
	if schema != SCHEMA_VERSION or content != CONTENT_VERSION:
		return {"status": "invalid", "path": path, "reason": "unsupported_old_version", "generation": int(envelope["generation"])}
	var validation := validate_snapshot(snapshot)
	if not validation.get("ok", false):
		return {"status": "invalid", "path": path, "reason": validation.get("error", "state"), "generation": int(envelope["generation"])}
	return {"status": "valid", "path": path, "generation": int(envelope["generation"]), "snapshot": snapshot}

func validate_snapshot(snapshot: Dictionary) -> Dictionary:
	if int(snapshot.get("generation", -1)) < 0:
		return {"ok": false, "error": "generation"}
	if not snapshot.has("campaign_id") or str(snapshot.get("campaign_id", "")).is_empty():
		return {"ok": false, "error": "campaign_id"}
	var solved: Variant = snapshot.get("solved")
	if typeof(solved) != TYPE_ARRAY:
		return {"ok": false, "error": "solved_type"}
	var seen_solved: Dictionary = {}
	var progression: Dictionary = puzzles_contract.get("progression", {})
	for raw_stage: Variant in solved:
		var stage := str(raw_stage)
		if stage not in PUZZLE_IDS or seen_solved.has(stage):
			return {"ok": false, "error": "solved_id"}
		for raw_req: Variant in progression.get(stage, []):
			if not seen_solved.has(str(raw_req)):
				return {"ok": false, "error": "solved_prerequisite"}
		seen_solved[stage] = true

	var hints: Variant = snapshot.get("hints", {})
	if typeof(hints) != TYPE_DICTIONARY:
		return {"ok": false, "error": "hints_type"}
	for stage in ["p01", "p02", "p03", "p04", "p05", "p06", "p07"]:
		var level := int((hints as Dictionary).get(stage, 0))
		if level < 0 or level > 3:
			return {"ok": false, "error": "hint_range"}

	var states: Variant = snapshot.get("puzzles")
	if typeof(states) != TYPE_DICTIONARY:
		return {"ok": false, "error": "puzzles_type"}
	var state_check := _validate_puzzle_states(states)
	if not state_check.get("ok", false):
		return state_check

	var narrative: Variant = snapshot.get("narrative")
	if typeof(narrative) != TYPE_DICTIONARY:
		return {"ok": false, "error": "narrative_type"}
	var narr: Dictionary = narrative
	var ack: Array = narr.get("acknowledged", [])
	var pending: Array = narr.get("pending", [])
	var active: Variant = narr.get("active_scene")
	var unique: Dictionary = {}
	for raw_scene: Variant in ack + pending:
		var scene := str(raw_scene)
		if scene not in NARRATIVE_IDS or unique.has(scene):
			return {"ok": false, "error": "narrative_id"}
		unique[scene] = true
	if active != null and str(active) not in NARRATIVE_IDS:
		return {"ok": false, "error": "active_scene"}
	if bool(snapshot.get("completed", false)) and "n11" not in ack:
		return {"ok": false, "error": "completed_without_n11"}
	return {"ok": true}

func _validate_puzzle_states(states: Dictionary) -> Dictionary:
	for puzzle_id in PUZZLE_IDS:
		if not states.has(puzzle_id) or typeof(states[puzzle_id]) != TYPE_DICTIONARY:
			return {"ok": false, "error": "missing_state_%s" % puzzle_id}
	var p00: Dictionary = states["p00"]
	var latches: Array = p00.get("latches", [])
	if latches.size() != 2:
		return {"ok": false, "error": "p00_latches"}
	var p01_order: Array = states["p01"].get("order", [])
	if not _same_members(p01_order, puzzles_contract["p01"]["pieces"].keys()):
		return {"ok": false, "error": "p01_order"}
	var p02_order: Array = states["p02"].get("order", [])
	if not _same_members(p02_order, puzzles_contract["p02"]["observations"].keys()):
		return {"ok": false, "error": "p02_order"}
	var bits: Array = states["p03"].get("bits", [])
	if bits.size() != 6:
		return {"ok": false, "error": "p03_bits"}
	for bit: Variant in bits:
		if int(bit) not in [0, 1]:
			return {"ok": false, "error": "p03_bit_value"}
	var turns: Array = states["p04"].get("turns", [])
	if turns.size() != 3:
		return {"ok": false, "error": "p04_turns"}
	for turn: Variant in turns:
		if int(turn) < 0 or int(turn) > 3:
			return {"ok": false, "error": "p04_turn_value"}
	var p05_slots: Array = states["p05"].get("slots", [])
	if p05_slots.size() != 6 or not _unique_known_or_null(p05_slots, puzzles_contract["p05"]["weights"].keys()):
		return {"ok": false, "error": "p05_slots"}
	for raw_item: Variant in puzzles_contract["p05"]["central_only"]:
		var item := str(raw_item)
		var index := p05_slots.find(item)
		if index >= 0 and abs(int(puzzles_contract["p05"]["positions"][index])) != 1:
			return {"ok": false, "error": "p05_gauge"}
	var p06: Dictionary = states["p06"]
	if int(p06.get("water_level", -1)) not in puzzles_contract["p06"]["water_levels"]:
		return {"ok": false, "error": "p06_water"}
	var placements: Dictionary = p06.get("fragments", {})
	for fragment_id in puzzles_contract["p06"]["fragments"].keys():
		var target: Variant = placements.get(fragment_id)
		if target != null and str(target) not in puzzles_contract["p06"]["fragments"][fragment_id]["destinations"]:
			return {"ok": false, "error": "p06_fragment"}
	var routes: Dictionary = p06.get("routes", {})
	for group_id in puzzles_contract["p06"]["groups"].keys():
		var route: Variant = routes.get(group_id, [])
		if typeof(route) != TYPE_ARRAY:
			return {"ok": false, "error": "p06_route_type"}
		var route_seen: Dictionary = {}
		for raw_node: Variant in route:
			var node := str(raw_node)
			if not puzzles_contract["p06"]["nodes"].has(node) or route_seen.has(node):
				return {"ok": false, "error": "p06_route_node"}
			route_seen[node] = true
	var p07: Dictionary = states["p07"]
	var donor: Variant = p07.get("donor")
	if donor != null and not puzzles_contract["p07"]["donors"].has(str(donor)):
		return {"ok": false, "error": "p07_donor"}
	var p07_slots: Array = p07.get("slots", [])
	if p07_slots.size() != 6 or not _unique_known_or_null(p07_slots, puzzles_contract["p07"]["actions"]):
		return {"ok": false, "error": "p07_slots"}
	return {"ok": true}

func _same_members(values: Array, expected: Array) -> bool:
	if values.size() != expected.size():
		return false
	var seen: Dictionary = {}
	for raw_value: Variant in values:
		var value := str(raw_value)
		if value not in expected or seen.has(value):
			return false
		seen[value] = true
	return true

func _unique_known_or_null(values: Array, expected: Array) -> bool:
	var seen: Dictionary = {}
	for raw_value: Variant in values:
		if raw_value == null:
			continue
		var value := str(raw_value)
		if value not in expected or seen.has(value):
			return false
		seen[value] = true
	return true

func _choose_target(a: Dictionary, b: Dictionary) -> Dictionary:
	if a.get("status") != "valid":
		return a
	if b.get("status") != "valid":
		return b
	return a if int(a.get("generation", 0)) <= int(b.get("generation", 0)) else b

func _preserve_diagnostic(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	_write_text(path + ".invalid_backup.json", FileAccess.get_file_as_string(path))

func _write_text(path: String, text: String) -> bool:
	_ensure_root()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	file.close()
	return true

func _sha256(text: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(text.to_utf8_buffer())
	return context.finish().hex_encode()

func _ensure_root() -> void:
	if root_path.begins_with("user://"):
		var absolute := ProjectSettings.globalize_path(root_path)
		DirAccess.make_dir_recursive_absolute(absolute)

func _path(filename: String) -> String:
	return root_path + "/" + filename if not root_path.is_empty() else filename

func _slot_path(slot_name: String) -> String:
	return _path("campaign_%s.json" % slot_name)
