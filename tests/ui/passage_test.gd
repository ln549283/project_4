extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const SequenceRules = preload("res://src/rules/sequence_rules.gd")\nconst P07DonorBoard = preload("res://src/ui/p07_donor_board.gd")\nconst P07TimelineBoard = preload("res://src/ui/p07_timeline_board.gd")

var failures: Array[String] = []

func _init() -> void:
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	_expect(ResourceLoader.exists("res://scenes/puzzles/p07.tscn"), "p07 scene exists")
	var contract: Dictionary = loaded["data"]["puzzles"]["p07"]
	var donor_board := P07DonorBoard.new()
	donor_board.size = Vector2(984, 560)
	donor_board.configure(contract["donors"], "")
	donor_board._rebuild_geometry()
	_expect_eq(donor_board.donor_rects.size(), 3, "p07A greybox exposes three visual candidates")
	donor_board.free()
	var timeline := P07TimelineBoard.new()
	timeline.size = Vector2(984, 500)
	timeline.configure([null, null, null, null, null, null], "")
	timeline._rebuild_geometry()
	_expect_eq(timeline.phase_rects.size(), 6, "p07B greybox exposes six visual phases")
	timeline.free()
	_expect(SequenceRules.validate_donor("floor", contract).get("valid", false), "floor donor accepted")
	_expect(not SequenceRules.validate_donor("door", contract).get("valid", true), "door rejected")
	_expect(not SequenceRules.validate_donor("roof", contract).get("valid", true), "roof rejected")
	_expect(SequenceRules.validate_sequence(contract["solution"], contract).get("valid", false), "canonical sequence accepted")
	var state := GameStateScript.new()
	state.configure(loaded["data"])
	state.new_campaign("t10")
	for action: Variant in contract["initial_tray"]:
		_expect(state.place_p07_action(str(action), contract["initial_tray"].find(action)).get("ok", false), "action placement accepted")
	_expect(state.place_p07_action("release", -1).get("ok", false), "action can return to tray")
	_finish()

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("T10 PASSAGE TEST PASS: visual donor/timeline and sequence interactions")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
