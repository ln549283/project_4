extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const SaveServiceClass = preload("res://src/core/save_service.gd")

const ROOT := "user://t04_test"
var failures: Array[String] = []

func _init() -> void:
	_cleanup()
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	var state := GameStateScript.new()
	state.configure(loaded["data"])
	state.new_campaign("save-test")
	var service := SaveServiceClass.new(loaded["data"]["puzzles"], ROOT)

	_test_generations(service, state)
	_test_interruptions(service, state)
	_test_invalid_recovery(service, state)
	_test_future_version(service, state)
	_test_disk_refused(service, state)
	_test_conclusion_resume(service, state)
	_test_settings(service)
	_cleanup()
	_finish()

func _test_generations(service: RefCounted, state: Node) -> void:
	var first: Dictionary = service.save_campaign(state.campaign)
	_expect(first.get("ok", false), "first save: %s" % first)
	_expect_eq(first.get("generation"), 1, "first generation")
	state.resolve_puzzle("p00")
	var second: Dictionary = service.save_campaign(state.campaign)
	_expect(second.get("ok", false), "second save: %s" % second)
	_expect_eq(second.get("generation"), 2, "second generation")
	var loaded: Dictionary = service.load_campaign()
	_expect_eq(loaded.get("generation"), 2, "load newest generation")
	_expect("p00" in loaded["snapshot"]["solved"], "newest payload selected")
	_expect(service.backup_for_restart().get("ok", false), "restart backup created")
	_expect(FileAccess.file_exists(ROOT + "/campaign_restart_backup.json"), "restart backup exists")

func _test_interruptions(service: RefCounted, state: Node) -> void:
	for phase in ["after_tmp_write", "after_tmp_verify", "after_target_remove"]:
		var result: Dictionary = service.save_campaign(state.campaign, phase)
		_expect(not result.get("ok", true), "simulated failure %s" % phase)
		var recovered: Dictionary = service.load_campaign()
		_expect(recovered.get("status") in ["ok", "recovered"], "valid older slot survives %s" % phase)
		_expect(int(recovered.get("generation", 0)) >= 1, "generation survives %s" % phase)
	var after_replace: Dictionary = service.save_campaign(state.campaign, "after_replace")
	_expect(not after_replace.get("ok", true), "after_replace reports failure")
	var loaded: Dictionary = service.load_campaign()
	_expect(int(loaded.get("generation", 0)) == int(after_replace.get("generation", -1)), "replace may have persisted despite lost acknowledgement")

func _test_invalid_recovery(service: RefCounted, state: Node) -> void:
	var good: Dictionary = service.save_campaign(state.campaign)
	_expect(good.get("ok", false), "good save before corruption: %s" % good)
	var newest_path := str(good.get("path", ""))
	var f := FileAccess.open(newest_path, FileAccess.WRITE)
	f.store_string("{broken")
	f.close()
	var loaded: Dictionary = service.load_campaign()
	_expect_eq(loaded.get("status"), "recovered", "one corrupt slot recovers previous generation")
	_expect(loaded.get("snapshot") != null, "recovery returns snapshot")
	var repair: Dictionary = service.save_campaign(loaded["snapshot"])
	_expect(repair.get("ok", false), "save after recovery")
	_expect(FileAccess.file_exists(newest_path + ".invalid_backup.json"), "invalid slot preserved diagnostically")

func _test_future_version(service: RefCounted, state: Node) -> void:
	_cleanup_slots()
	var future: Dictionary = state.campaign.duplicate(true)
	future["schema_version"] = 2
	future["content_version"] = "2.0"
	future["generation"] = 99
	_expect(service.write_envelope_for_test("a", future), "write future fixture")
	var loaded: Dictionary = service.load_campaign()
	_expect_eq(loaded.get("status"), "future_version", "future version blocks destructive load")
	var save: Dictionary = service.save_campaign(state.campaign)
	_expect_eq(save.get("error"), "future_version_present", "future version blocks writes")
	_cleanup_slots()

func _test_disk_refused(service: RefCounted, state: Node) -> void:
	var before: Dictionary = service.load_campaign()
	var result: Dictionary = service.save_campaign(state.campaign, "disk_refused")
	_expect_eq(result.get("error"), "write_refused", "disk refusal explicit")
	var after: Dictionary = service.load_campaign()
	_expect_eq(after.get("generation", 0), before.get("generation", 0), "disk refusal does not fake persistence")

func _test_conclusion_resume(service: RefCounted, state: Node) -> void:
	_cleanup_slots()
	var snapshot: Dictionary = state.campaign.duplicate(true)
	snapshot["solved"] = state.puzzles_contract.campaign_order.filter(func(id): return id != "ending")
	snapshot["completed"] = false
	snapshot["narrative"]["pending"] = ["n11"]
	snapshot["narrative"]["acknowledged"] = ["n00", "n01", "n02", "n03", "n04", "n05", "n06", "n07", "n08", "n09", "n10"]
	snapshot["narrative"]["active_scene"] = null
	var conclusion_save: Dictionary = service.save_campaign(snapshot)
	_expect(conclusion_save.get("ok", false), "save pending conclusion: %s" % conclusion_save)
	var loaded: Dictionary = service.load_campaign()
	_expect(not bool(loaded["snapshot"]["completed"]), "p07 solved does not imply completed")
	_expect("n11" in loaded["snapshot"]["narrative"]["pending"], "conclusion resumes at n11")

func _test_settings(service: RefCounted) -> void:
	var defaults := {"text_scale": 1.0, "music": 0.7, "sfx": 0.8}
	_expect(service.save_settings({"text_scale": 1.5, "music": 0.4}).get("ok", false), "settings save")
	var loaded: Dictionary = service.load_settings(defaults)
	_expect_eq(loaded["settings"]["text_scale"], 1.5, "settings override")
	_expect_eq(loaded["settings"]["sfx"], 0.8, "settings defaults merged")

func _cleanup_slots() -> void:
	for name in ["campaign_a.json", "campaign_b.json", "campaign_a.json.tmp", "campaign_b.json.tmp", "campaign_a.json.invalid_backup.json", "campaign_b.json.invalid_backup.json", "campaign_restart_backup.json"]:
		var path: String = ROOT + "/" + name
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _cleanup() -> void:
	_cleanup_slots()
	for name in ["settings.json", "settings.json.tmp", "settings_backup.json"]:
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
		print("T04 SAVE TEST PASS: generations, corruption, interruptions, future versions and conclusion resume")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
