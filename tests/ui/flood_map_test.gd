extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const FloodMapRules = preload("res://src/rules/flood_map_rules.gd")
const P06MapBoard = preload("res://src/ui/p06_map_board.gd")

var failures: Array[String] = []

func _init() -> void:
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	_expect(ResourceLoader.exists("res://scenes/puzzles/p06.tscn"), "p06 scene exists")
	var contract: Dictionary = loaded["data"]["puzzles"]["p06"]
	_expect(ResourceLoader.exists("res://src/ui/p06_map_board.gd"), "p06 visual greybox exists")
	var canonical := {
		"water_level": 4,
		"fragments": {"arcade": "jk", "ramp": "kl"},
		"routes": {
			"school": ["S", "J", "K", "C"],
			"infirmary": ["I", "J", "K", "L", "H"],
			"archives": ["A", "J", "K", "L", "G"],
		},
	}
	_expect(FloodMapRules.validate(canonical, contract).get("valid", false), "canonical p06 accepted")
	var alternate: Dictionary = canonical.duplicate(true)
	alternate["routes"]["archives"] = ["A", "J", "K", "H", "L", "G"]
	_expect(FloodMapRules.validate(alternate, contract).get("valid", false), "alternate archives path accepted")

	var state := GameStateScript.new()
	state.configure(loaded["data"])
	state.new_campaign("t09")
	state.set_route("school", ["S", "J"])
	var before: Array = state.campaign["puzzles"]["p06"]["routes"]["school"].duplicate()
	state.set_water_level(4)
	state.place_fragment("arcade", "jk")
	_expect_eq(state.campaign["puzzles"]["p06"]["routes"]["school"], before, "water/fragment changes preserve route draft")
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _finish() -> void:
	if failures.is_empty():
		print("T09 FLOOD MAP TEST PASS: visual map, two accepted route variants and draft preservation")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
