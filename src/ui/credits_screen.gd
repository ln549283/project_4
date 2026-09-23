extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	Session.router.current_view = "s14"
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, "Générique / exploration")
	box.add_child(UiFactory.make_label("Greybox interne — crédits et licences définitifs seront intégrés avant livraison.", Session.font_size_px(18)))
	if bool(Session.state.campaign.get("completed", false)):
		box.add_child(UiFactory.make_label("Exploration en lecture seule des reconstitutions terminées.", Session.font_size_px(18)))
	box.add_child(UiFactory.make_button("Retour", _back, true))

func _back() -> void:
	if not Session.go_back().get("ok", false):
		Session.navigate("s00", false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		get_viewport().set_input_as_handled()
