extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	Session.router.current_view = "s13"
	_rebuild()
	Session.call_deferred("present_pending_narrative")

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, "Le passage retrouvé", "Compléter le cartel")
	var town := TextureRect.new()
	town.texture = preload("res://assets/production/panorama.webp")
	town.custom_minimum_size.y = 580
	town.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	town.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	town.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(town)
	var acknowledged: Array = Session.state.campaign["narrative"]["acknowledged"]
	box.add_child(UiFactory.make_label("Témoignage d'Aline", Session.font_size_px(18)))
	box.add_child(UiFactory.make_label(str(Session.evidence_texts.get("evidence_statement", "")), Session.font_size_px(16)))
	box.add_child(UiFactory.make_label("Rapport provisoire", Session.font_size_px(18)))
	box.add_child(UiFactory.make_label(str(Session.evidence_texts.get("evidence_report", "")), Session.font_size_px(16)))
	if "n09" in acknowledged and "n10" not in acknowledged and not _narrative_exists("n10"):
		box.add_child(UiFactory.make_button("Ajouter les preuves", _add_evidence, true))
	if "n10" in acknowledged or _narrative_exists("n10") or _narrative_exists("n11"):
		box.add_child(UiFactory.make_label("Cartel corrigé", Session.font_size_px(18)))
		box.add_child(UiFactory.make_label(str(Session.evidence_texts.get("evidence_cartel_final", "")), Session.font_size_px(16)))
	if bool(Session.state.campaign.get("completed", false)):
		box.add_child(UiFactory.make_button("Explorer la maquette", func(): Session.navigate("s14", false), true))
	box.add_child(UiFactory.make_button("Carnet", func(): Session.open_notebook()))
	box.add_child(UiFactory.make_button("Pause", _pause))

func _narrative_exists(id: String) -> bool:
	var narrative: Dictionary = Session.state.campaign["narrative"]
	return narrative.get("active_scene") == id or id in narrative.get("pending", [])

func _add_evidence() -> void:
	Session.state.queue_narrative("n10")
	Session.save_now()
	Session.present_pending_narrative()
	_rebuild()

func _pause() -> void:
	var overlay := preload("res://scenes/ui/pause.tscn").instantiate()
	add_child(overlay)

func on_narrative_closed() -> void:
	_rebuild()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_pause()
		get_viewport().set_input_as_handled()
