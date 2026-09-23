extends Node

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const SaveServiceClass = preload("res://src/core/save_service.gd")
const SceneRouterClass = preload("res://src/core/scene_router.gd")

const ROUTES := {
	"s00": "res://scenes/home.tscn",
	"s01": "res://scenes/settings.tscn",
	"s02": "res://scenes/workbench.tscn",
	"s03": "res://scenes/archive.tscn",
	"s04": "res://scenes/window.tscn",
	"s05": "res://scenes/puzzles/p01.tscn",
	"s06": "res://scenes/puzzles/p02.tscn",
	"s12": "res://scenes/ui/notebook.tscn",
	"s14": "res://scenes/credits.tscn",
}
const DEFAULT_SETTINGS := {
	"text_scale": 1.0,
	"music": 0.7,
	"sfx": 0.8,
	"vibration": true,
	"reduced_motion": false,
	"high_contrast": false,
	"locale": "fr",
}

var state: Node
var save_service: RefCounted
var router: RefCounted
var settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)
var load_status := "uninitialized"
var recovery_message := ""
var campaign_started := false
var view_state := {
	"pinned_evidence": null,
	"compare_evidence": [],
}

func _ready() -> void:
	initialize()

func initialize() -> Dictionary:
	if state != null:
		return {"ok": true, "status": load_status}
	var loaded := ContractLoader.load_and_validate()
	if not loaded.get("ok", false):
		load_status = "contract_error"
		return {"ok": false, "errors": loaded.get("errors", [])}
	state = GameStateScript.new()
	add_child(state)
	state.configure(loaded["data"])
	save_service = SaveServiceClass.new(loaded["data"]["puzzles"])
	router = SceneRouterClass.new(ROUTES)
	settings = save_service.load_settings(DEFAULT_SETTINGS).get("settings", DEFAULT_SETTINGS.duplicate(true))
	var campaign_load: Dictionary = save_service.load_campaign()
	load_status = str(campaign_load.get("status", "new"))
	match load_status:
		"ok", "recovered":
			state.campaign = (campaign_load["snapshot"] as Dictionary).duplicate(true)
			state.dirty = false
			campaign_started = true
			if load_status == "recovered":
				recovery_message = "La dernière sauvegarde était incomplète. La précédente a été récupérée."
		"new":
			state.new_campaign(_new_campaign_id())
			state.dirty = false
			campaign_started = false
		"future_version":
			state.new_campaign(_new_campaign_id())
			state.dirty = false
			campaign_started = false
			recovery_message = "Partie issue d'une version plus récente. Aucun fichier ne sera écrasé."
		"unreadable":
			state.new_campaign(_new_campaign_id())
			state.dirty = false
			campaign_started = false
			recovery_message = "La sauvegarde n'a pas pu être lue. Une nouvelle partie doit être confirmée."
	return {"ok": true, "status": load_status}

func has_saved_campaign() -> bool:
	return campaign_started

func start_new_game() -> Dictionary:
	if load_status == "future_version":
		return {"ok": false, "error": "future_version_present"}
	if campaign_started:
		save_service.backup_for_restart()
	state.new_campaign(_new_campaign_id())
	campaign_started = true
	load_status = "ok"
	router.stack.clear()
	var saved := save_now()
	if not saved.get("ok", false):
		return saved
	return navigate("s02", false)

func continue_game() -> Dictionary:
	if not campaign_started:
		return {"ok": false, "error": "no_saved_campaign"}
	return navigate(_resume_view(), false)

func save_now() -> Dictionary:
	if state == null or not campaign_started:
		return {"ok": false, "error": "no_active_campaign"}
	var result: Dictionary = save_service.save_campaign(state.campaign)
	if result.get("ok", false):
		state.campaign["generation"] = result["generation"]
		state.campaign["saved_at_utc"] = result["snapshot"]["saved_at_utc"]
		state.dirty = false
		load_status = "ok"
	return result

func save_settings_now() -> Dictionary:
	return save_service.save_settings(settings)

func navigate(view_id: String, push_history: bool = true) -> Dictionary:
	var route_result: Dictionary = router.push(view_id) if push_history else router.replace(view_id)
	if not route_result.get("ok", false):
		return route_result
	if campaign_started and view_id != "s00":
		state.campaign["location"] = {"view": view_id, "subview": "", "focus": ""}
		state.dirty = true
		save_now()
	var error := get_tree().change_scene_to_file(route_result["path"])
	return {"ok": error == OK, "error_code": error, "view_id": view_id}

func go_back() -> Dictionary:
	var result: Dictionary = router.back()
	if not result.get("ok", false):
		return result
	if campaign_started and result["view_id"] != "s00":
		state.campaign["location"] = {"view": result["view_id"], "subview": "", "focus": ""}
		state.dirty = true
		save_now()
	var error := get_tree().change_scene_to_file(result["path"])
	return {"ok": error == OK, "error_code": error}

func open_notebook() -> Dictionary:
	return navigate("s12")

func close_notebook() -> Dictionary:
	return go_back()

func current_objective() -> String:
	var solved: Array = state.campaign.get("solved", [])
	if "p00" not in solved:
		return "Ouvrir le coffret"
	if "p01" not in solved:
		return "Raccorder le panorama"
	if "p02" not in solved:
		return "Retrouver l'ordre des photographies"
	if "p03" not in solved and "p04" not in solved:
		return "Choisir : chemins de service ou contrejour"
	if "p03" not in solved:
		return "Retrouver les chemins de service"
	if "p04" not in solved:
		return "Comprendre la silhouette"
	if "p05" not in solved:
		return "Stabiliser la cargaison"
	if "p06" not in solved:
		return "Retrouver les chemins vers les refuges"
	if "p07" not in solved:
		return "Expliquer le passage vers le quai"
	if not bool(state.campaign.get("completed", false)):
		return "Ajouter les preuves au cartel"
	return "Explorer la maquette"

func font_size_px(base_sp: int = 18) -> int:
	return roundi(float(base_sp * 3) * float(settings.get("text_scale", 1.0)))

func set_text_scale(scale: float) -> void:
	if scale not in [1.0, 1.25, 1.5]:
		return
	settings["text_scale"] = scale
	save_settings_now()

func toggle_setting(key: String) -> void:
	if key not in ["vibration", "reduced_motion", "high_contrast"]:
		return
	settings[key] = not bool(settings.get(key, false))
	save_settings_now()

func evidence_item(evidence_id: String) -> Dictionary:
	for raw_item: Variant in state.evidence_contract.get("items", []):
		var item: Dictionary = raw_item
		if str(item.get("id", "")) == evidence_id:
			return item
	return {}

func pin_evidence(evidence_id: String) -> void:
	if evidence_id in state.available_evidence():
		view_state["pinned_evidence"] = evidence_id
		state.mark_evidence_seen(evidence_id)
		save_now()

func toggle_compare_evidence(evidence_id: String) -> void:
	if evidence_id not in state.available_evidence():
		return
	var compare: Array = view_state["compare_evidence"]
	if evidence_id in compare:
		compare.erase(evidence_id)
	else:
		if compare.size() >= 2:
			compare.pop_front()
		compare.append(evidence_id)
	state.mark_evidence_seen(evidence_id)
	save_now()

func _resume_view() -> String:
	var view := str(state.campaign.get("location", {}).get("view", "s02"))
	return view if router.has_route(view) else "s02"

func _new_campaign_id() -> String:
	return "local-%s" % str(Time.get_unix_time_from_system())
