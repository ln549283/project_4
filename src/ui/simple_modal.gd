extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

@export var title := "Information"
@export_multiline var message := ""

func configure(new_title: String, new_message: String) -> void:
	title = new_title
	message = new_message

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.12, 0.14, 0.92)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(bg, title)
	box.add_child(UiFactory.make_label(message, Session.font_size_px(18)))
	box.add_child(UiFactory.make_button("Fermer", queue_free, true))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
