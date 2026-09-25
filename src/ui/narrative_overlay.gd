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
	if Session.presentation_audio != null: Session.presentation_audio.duck_narrative(true)
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var bg := ColorRect.new()
	bg.color = Color("0b1c22")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var backdrop := preload("res://src/presentation/room_backdrop.gd").new()
	backdrop.shade = 0.78
	bg.add_child(backdrop)
	var box := UiFactory.make_page(bg, "")
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 120
	box.add_child(spacer)
	var index := clampi(int(Session.state.campaign["narrative"].get("segment", 0)), 0, segments.size() - 1)
	var words := str(segments[index])
	var speaker := words.get_slice(" :",0) if " :" in words else "Orme-sur-Rive"
	if speaker in ["Jo","Aline"]:
		var portrait := TextureRect.new()
		portrait.texture = preload("res://src/presentation/production_art.gd").texture(6 if speaker == "Jo" else 7)
		portrait.custom_minimum_size.y = 300
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(portrait)
	var heading := UiFactory.make_label(speaker,64)
	heading.add_theme_font_override("font",preload("res://assets/slice/lantern/title.ttf"))
	box.add_child(heading)
	var text := words.substr(words.find(" :")+2).strip_edges() if " :" in words else words
	box.add_child(UiFactory.make_label(text, Session.font_size_px(18)))
	var breathing := Control.new()
	breathing.custom_minimum_size.y = 72
	box.add_child(breathing)
	box.add_child(UiFactory.make_button("Continuer", _next, true))
	box.add_child(UiFactory.make_button("Revenir au jeu", queue_free))

func _exit_tree() -> void:
	var session := get_node_or_null("/root/Session")
	if session != null and is_instance_valid(session.presentation_audio):
		session.presentation_audio.duck_narrative(false)

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
