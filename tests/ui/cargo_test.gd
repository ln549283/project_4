extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const CargoRules = preload("res://src/rules/cargo_rules.gd")
const P05CargoBoard = preload("res://src/ui/p05_cargo_board.gd")

var failures: Array[String] = []

func _init() -> void:
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	_expect(ResourceLoader.exists("res://scenes/puzzles/p05.tscn"), "p05 scene exists")
	var contract: Dictionary = loaded["data"]["puzzles"]["p05"]
	_expect(ResourceLoader.exists("res://src/ui/p05_cargo_board.gd"), "p05 visual greybox exists")
	var known_solutions := [
		["medicine", "tools", "press", "lantern", "dye", "food"],
		["food", "dye", "lantern", "press", "tools", "medicine"],
		["tools", "medicine", "press", "lantern", "food", "dye"],
		["dye", "food", "lantern", "press", "medicine", "tools"],
	]
	for solution: Variant in known_solutions:
		_expect(CargoRules.validate(solution, contract).get("valid", false), "documented cargo solution accepted")
	var state := GameStateScript.new()
	state.configure(loaded["data"])
	state.new_campaign("t08")
	_expect(not state.place_cargo("press", 0).get("ok", true), "press external placement refused")
	_expect(state.place_cargo("press", 2).get("ok", false), "press central placement accepted")
	_expect(state.place_cargo("press", -1).get("ok", false), "cargo can always return to tray")
	_finish()

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("T08 CARGO TEST PASS: visual balance, four solutions and recoverable placements")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
