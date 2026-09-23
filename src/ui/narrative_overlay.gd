extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

var scene_id := ""
var segments: Array = []

func configure(id: String) -> void:
	scene_id = id

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content := _load_content()
	segments = content.get("scenes", {}).get(scene_id, [])
	if segments.is_empty():
		push_error("Narrative scene missing: " + scene_id)
		Session.state.acknowledge_narrative(scene_id)
		Session.on_narrative_acknowledged(scene_id)
		queue_free()
		return
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.10, 0.12, 0.97)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(bg, "Récit")
	var index := clampi(int(Session.state.campaign["narrative"].get("segment", 0)), 0, segments.size() - 1)
	box.add_child(UiFactory.make_label(str(segments[index]), Session.font_size_px(18)))
	box.add_child(UiFactory.make_button("Continuer", _next, true))
	box.add_child(UiFactory.make_button("Fermer", queue_free))

func _next() -> void:
	var narrative: Dictionary = Session.state.campaign["narrative"]
	var index := int(narrative.get("segment", 0)) + 1
	if index < segments.size():
		narrative["segment"] = index
		Session.state.dirty = true
		Session.save_now()
		_rebuild()
		return
	Session.state.acknowledge_narrative(scene_id)
	Session.save_now()
	queue_free()
	Session.on_narrative_acknowledged(scene_id)

func _load_content() -> Dictionary:
	if not FileAccess.file_exists("res://content/dialogue_fr.json"):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://content/dialogue_fr.json"))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
