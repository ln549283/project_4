extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")
var evidence_id := ""
var body := ""

func configure(id: String, text: String) -> void:
	evidence_id = id
	body = text

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var panel := ColorRect.new()
	panel.color = Color(0.95, 0.91, 0.84, 0.98)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var box := UiFactory.make_page(panel, evidence_id)
	box.add_child(UiFactory.make_label(body, Session.font_size_px(18)))
	box.add_child(UiFactory.make_button("Épingler", func(): Session.pin_evidence(evidence_id)))
	box.add_child(UiFactory.make_button("Comparer", func(): Session.toggle_compare_evidence(evidence_id)))
	box.add_child(UiFactory.make_button("Fermer", queue_free, true))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
