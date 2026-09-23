extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")
var puzzle_id := ""

func configure(id: String) -> void:
	puzzle_id = id

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.12, 0.14, 0.95)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(bg, "Indice")
	var ladder: Array = Session.state.hints_contract.get(puzzle_id, [])
	var level := int(Session.state.campaign["hints"].get(puzzle_id, 0))
	if level == 0:
		box.add_child(UiFactory.make_label("Une piste, sans résoudre à votre place.", Session.font_size_px(18)))
	for i in range(level):
		box.add_child(UiFactory.make_label("Piste %d — %s" % [i + 1, str(ladder[i])], Session.font_size_px(18)))
	if level < 3:
		var label := "Afficher une piste" if level == 0 else "Une autre piste"
		box.add_child(UiFactory.make_button(label, _reveal))
	else:
		box.add_child(UiFactory.make_label("Les trois pistes sont affichées.", Session.font_size_px(16)))
	box.add_child(UiFactory.make_button("Fermer", queue_free, true))

func _reveal() -> void:
	var current := int(Session.state.campaign["hints"].get(puzzle_id, 0))
	Session.state.set_hint_level(puzzle_id, mini(current + 1, 3))
	Session.save_now()
	_rebuild()
