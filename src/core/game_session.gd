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
	"s07": "res://scenes/puzzles/p03.tscn",
	"s08": "res://scenes/puzzles/p04.tscn",
	"s09": "res://scenes/puzzles/p05.tscn",
	"s10": "res://scenes/puzzles/p06.tscn",
	"s11": "res://scenes/puzzles/p07.tscn",
	"s13": "res://scenes/ending.tscn",
	"s12": "res://scenes/ui/notebook.tscn",
	"s14": "res://scenes/credits.tscn",
	"p08": "res://scenes/puzzles/p08.tscn",
	"p09": "res://scenes/puzzles/p09.tscn",
	"p10": "res://scenes/puzzles/p10.tscn",
	"p11": "res://scenes/puzzles/p11.tscn",
	"p12": "res://scenes/puzzles/p12.tscn",
	"p13": "res://scenes/puzzles/p13.tscn",
	"p14": "res://scenes/puzzles/p14.tscn",
	"p15": "res://scenes/puzzles/p15.tscn",
	"p16": "res://scenes/puzzles/p16.tscn",
	"p17": "res://scenes/puzzles/p17.tscn",

}
const STAGE_VIEWS := {"p00":"s02","p01":"s05","p02":"s06","p03":"s07","p04":"s08","p05":"s09","p06":"s10","p07":"s11","p08":"p08","p09":"p09","p10":"p10","p11":"p11","p12":"p12","p13":"p13","p14":"p14","p15":"p15","p16":"p16","p17":"p17","ending":"s13"}
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
	"exploration_mode": false,
}
var evidence_texts: Dictionary = {}

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
	evidence_texts = _load_json_dictionary("res://content/evidence_fr.json")
	var campaign_load: Dictionary = save_service.load_campaign()
	load_status = str(campaign_load.get("status", "new"))
	match load_status:
		"ok", "recovered":
			state.campaign = (campaign_load["snapshot"] as Dictionary).duplicate(true)
			state.dirty = false
			campaign_started = true
			if not state.campaign.get("legacy_solved",[]).is_empty():
				recovery_message = "Votre progression précédente est conservée. Dix nouveaux ateliers sont disponibles depuis l’établi."
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
	for stage: String in STAGE_VIEWS:
		if STAGE_VIEWS[stage] == view_id and stage != "p00" and not state.can_enter(stage):
			return {"ok":false,"error":"stage_locked"}
	var route_result: Dictionary = router.push(view_id) if push_history else router.replace(view_id)
	if not route_result.get("ok", false):
		return route_result
	if campaign_started and view_id != "s00":
		state.campaign["location"] = {"view": view_id, "subview": "", "focus": ""}
		state.dirty = true
		save_now()
	var error := get_tree().change_scene_to_file(route_result["path"])
	if error == OK:
		get_tree().process_frame.connect(present_pending_narrative, CONNECT_ONE_SHOT)
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
	if error == OK:
		get_tree().process_frame.connect(present_pending_narrative, CONNECT_ONE_SHOT)
	return {"ok": error == OK, "error_code": error}

func open_notebook() -> Dictionary:
	return navigate("s12")

func close_notebook() -> Dictionary:
	return go_back()

func next_stage() -> String:
	for raw_id: Variant in state.puzzles_contract.campaign_order:
		var id := str(raw_id)
		if id not in state.campaign.solved and state.can_enter(id):
			return id
	return "ending"

func objective_view() -> String:
	return str(STAGE_VIEWS.get(next_stage(),"s02"))

func current_objective() -> String:
	var stage := next_stage()
	var names := {"p00":"Ouvrir le coffret","p01":"Raccorder le panorama","p02":"Retrouver l'ordre des photographies","p03":"Retrouver les chemins de service","p04":"Comprendre la silhouette","p05":"Stabiliser la cargaison","p06":"Retrouver les chemins vers les refuges","p07":"Expliquer le passage vers le quai","ending":"Ajouter les preuves au cartel"}
	if state.puzzles_contract.get(stage,{}).has("goal"):
		return str(state.puzzles_contract[stage].goal)
	return str(names.get(stage,"Explorer la maquette"))

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
		var item: Dictionary = (raw_item as Dictionary).duplicate(true)
		if str(item.get("id", "")) == evidence_id:
			if evidence_texts.has(evidence_id):
				item["body"] = str(evidence_texts[evidence_id])
			return item
	return {}

func present_pending_narrative() -> void:
	if not campaign_started or get_tree().current_scene == null:
		return
	if router.current_view in ["s00", "s01", "s12", "s14"]:
		return
	if get_tree().current_scene.get_node_or_null("NarrativeOverlay") != null:
		return
	var scene_id: Variant = state.begin_next_narrative()
	if scene_id == null:
		return
	save_now()
	var overlay := preload("res://scenes/ui/narrative.tscn").instantiate()
	overlay.name = "NarrativeOverlay"
	overlay.configure(str(scene_id))
	get_tree().current_scene.add_child(overlay)

func on_narrative_acknowledged(scene_id: String) -> void:
	save_now()
	if get_tree().current_scene != null and get_tree().current_scene.has_method("on_narrative_closed"):
		get_tree().current_scene.call_deferred("on_narrative_closed")
	if scene_id == "n10":
		state.queue_narrative("n11")
		save_now()
	if scene_id == "n11":
		view_state["exploration_mode"] = true
		navigate("s14", false)
		return
	call_deferred("present_pending_narrative")

func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

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
