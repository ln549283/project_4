extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	Session.router.current_view = "s14"
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, "Générique / exploration")
	box.add_child(UiFactory.make_label("Greybox interne — crédits et licences définitifs seront intégrés avant livraison.", Session.font_size_px(18)))
	if bool(Session.state.campaign.get("completed", false)):
		box.add_child(UiFactory.make_label("Reconstitutions conservées en lecture seule.", Session.font_size_px(18)))
		for entry in [
			["s05", "Panorama"],
			["s06", "Photographies"],
			["s07", "Chemins de service"],
			["s08", "Contrejour"],
			["s09", "Barge"],
			["s10", "Quartier sous l'eau"],
			["s11", "Passage"],
		]:
			box.add_child(UiFactory.make_button(str(entry[1]), _explore.bind(str(entry[0]))))
		for i in range(8,18):
			var id := "p%02d" % i
			if id in Session.state.campaign.solved:
				box.add_child(UiFactory.make_button(str(Session.state.puzzles_contract[id].title),_explore.bind(id)))
	box.add_child(UiFactory.make_button("Établi — suite du travail",func(): Session.navigate("s02",false),true))
	box.add_child(UiFactory.make_button("Accueil", func(): Session.navigate("s00", false), true))

func _explore(view_id: String) -> void:
	Session.view_state["exploration_mode"] = true
	Session.navigate(view_id)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Session.navigate("s00", false)
		get_viewport().set_input_as_handled()
