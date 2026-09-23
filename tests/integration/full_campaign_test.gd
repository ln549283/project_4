extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const PanoramaRules = preload("res://src/rules/panorama_rules.gd")
const ChronologyRules = preload("res://src/rules/chronology_rules.gd")
const RoutesRules = preload("res://src/rules/routes_rules.gd")
const MasksRules = preload("res://src/rules/masks_rules.gd")
const CargoRules = preload("res://src/rules/cargo_rules.gd")
const FloodMapRules = preload("res://src/rules/flood_map_rules.gd")
const SequenceRules = preload("res://src/rules/sequence_rules.gd")
const SaveServiceClass = preload("res://src/core/save_service.gd")

var failures: Array[String] = []
const ROOT := "user://t11_full"

func _init() -> void:
	_cleanup()
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	var p: Dictionary = loaded["data"]["puzzles"]
	var state := GameStateScript.new()
	state.configure(loaded["data"])
	state.new_campaign("full-greybox")
	_ack_all(state)
	state.toggle_latch(0)
	state.toggle_latch(1)
	_expect(state.open_box().get("ok", false), "p00")
	_ack_all(state)

	state.campaign["puzzles"]["p01"]["order"] = p["p01"]["solution"].duplicate()
	_expect(PanoramaRules.validate(state.campaign["puzzles"]["p01"]["order"], p["p01"]).get("valid", false), "p01 validator")
	_expect(state.resolve_puzzle("p01").get("ok", false), "p01 resolve")
	_ack_all(state)

	state.campaign["puzzles"]["p02"]["order"] = p["p02"]["solution"].duplicate()
	_expect(ChronologyRules.validate(state.campaign["puzzles"]["p02"]["order"], p["p02"]).get("valid", false), "p02 validator")
	_expect(state.resolve_puzzle("p02").get("ok", false), "p02 resolve")
	_ack_all(state)

	state.campaign["puzzles"]["p04"]["turns"] = p["p04"]["solution"].duplicate()
	_expect(MasksRules.validate(state.campaign["puzzles"]["p04"]["turns"], p["p04"]).get("valid", false), "p04 validator")
	_expect(state.resolve_puzzle("p04").get("ok", false), "p04 first branch")
	_ack_all(state)

	state.campaign["puzzles"]["p03"]["bits"] = p["p03"]["solution"].duplicate()
	_expect(RoutesRules.validate(state.campaign["puzzles"]["p03"]["bits"], p["p03"], p["route_tile_pairs"]).get("valid", false), "p03 validator")
	_expect(state.resolve_puzzle("p03").get("ok", false), "p03 second branch")
	_ack_all(state)
	_expect(state.can_enter("p05"), "join unlocked")

	state.campaign["puzzles"]["p05"]["slots"] = p["p05"]["example_solution"].duplicate()
	_expect(CargoRules.validate(state.campaign["puzzles"]["p05"]["slots"], p["p05"]).get("valid", false), "p05 validator")
	_expect(state.resolve_puzzle("p05").get("ok", false), "p05 resolve")
	_ack_all(state)

	state.campaign["puzzles"]["p06"] = p["p06"]["solution"].duplicate(true)
	_expect(FloodMapRules.validate(state.campaign["puzzles"]["p06"], p["p06"]).get("valid", false), "p06 validator")
	_expect(state.resolve_puzzle("p06").get("ok", false), "p06 resolve")
	_ack_all(state)

	state.campaign["puzzles"]["p07"]["donor"] = "floor"
	state.campaign["puzzles"]["p07"]["part_a_solved"] = true
	state.campaign["puzzles"]["p07"]["slots"] = p["p07"]["solution"].duplicate()
	_expect(SequenceRules.validate("floor", state.campaign["puzzles"]["p07"]["slots"], p["p07"]).get("valid", false), "p07 validator")
	state.queue_narrative("n08")
	_ack_all(state)
	_expect(state.resolve_puzzle("p07").get("ok", false), "p07 resolve")
	state.queue_narrative("n09")
	_ack_all(state)
	state.queue_narrative("n10")
	_ack_all(state)
	state.queue_narrative("n11")
	_ack_all(state)
	_expect(bool(state.campaign["completed"]), "completed only after n11")
	_expect_eq(state.campaign["solved"], ["p00", "p01", "p02", "p04", "p03", "p05", "p06", "p07"], "full solved path")

	var service := SaveServiceClass.new(p, ROOT)
	_expect(service.save_campaign(state.campaign).get("ok", false), "completed campaign saves")
	var restored: Dictionary = service.load_campaign()
	_expect(restored.get("status") in ["ok", "recovered"], "completed campaign reloads")
	_expect(bool(restored["snapshot"]["completed"]), "completed survives reload")
	_expect_eq(restored["snapshot"]["solved"], state.campaign["solved"], "solved order survives reload")

	var narrative := _load_json("res://content/dialogue_fr.json")
	for id in ["n00", "n01", "n02", "n03", "n04", "n05", "n06", "n07", "n08", "n09", "n10", "n11"]:
		_expect(narrative.get("scenes", {}).has(id), "narrative scene exists " + id)
		_expect(not (narrative["scenes"][id] as Array).is_empty(), "narrative scene nonempty " + id)
	_cleanup()
	_finish()

func _ack_all(state: Node) -> void:
	while true:
		var scene: Variant = state.begin_next_narrative()
		if scene == null:
			return
		state.acknowledge_narrative(str(scene))

func _load_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _cleanup() -> void:
	for name in ["campaign_a.json", "campaign_b.json", "campaign_a.json.tmp", "campaign_b.json.tmp"]:
		var path: String = ROOT + "/" + name
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _finish() -> void:
	if failures.is_empty():
		print("T11 FULL CAMPAIGN TEST PASS: P00-P07, narrative N00-N11, save/reload, ending")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
