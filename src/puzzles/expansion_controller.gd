extends "res://src/ui/puzzle_screen_base.gd"
const Rules = preload("res://src/rules/expansion_rules.gd")
const Board = preload("res://src/ui/expansion_board.gd")
@export var puzzle_id := "p08"
var previous_state: Dictionary = {}
var selected := -1
var piece_turn := 0
var passengers: Array = []
var trace_visible := false
var scroll_y := 0

func _ready() -> void:
	Session.router.current_view = puzzle_id
	_rebuild()

func _contract() -> Dictionary:
	return Session.state.puzzles_contract[puzzle_id]

func _state() -> Dictionary:
	return Session.state.campaign.puzzles[puzzle_id]

func _rebuild() -> void:
	clear_page()
	var p := _contract()
	var box := setup_page(p.title, p.goal)
	if not Session.state.can_enter(puzzle_id):
		box.add_child(UiFactory.make_label("Terminez d'abord le travail précédent."))
		box.add_child(UiFactory.make_button("Établi",func(): Session.navigate("s02",false)))
		return
	box.add_child(UiFactory.make_label(p.intro, Session.font_size_px(16)))
	var board := Board.new()
	board.name = "PuzzleBoard"
	board.configure(p,_state(),selected,passengers,piece_turn,trace_visible,previous_state)
	previous_state = {}
	board.pressed.connect(_board_pressed)
	box.add_child(board)
	if puzzle_id in Session.state.campaign.solved:
		box.add_child(UiFactory.make_label("Reconstitution terminée — consultation."))
		box.add_child(UiFactory.make_button("Continuer",func(): Session.navigate("s02",false)))
		return
	_add_controls(box,p)
	if not feedback.is_empty():
		box.add_child(UiFactory.make_label(feedback, Session.font_size_px(18)))
	add_common_tools(box,puzzle_id,_verify,func(): ask_reset(_reset),_undo,_instructions())
	var scroll: ScrollContainer = box.get_parent()
	scroll.set_deferred("scroll_vertical",scroll_y)

func _row(box: VBoxContainer) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",24)
	box.add_child(row)
	return row

func _add_controls(box: VBoxContainer,p: Dictionary) -> void:
	match str(p.kind):
		"facades":
			box.add_child(UiFactory.make_label("Croquis — voisins immédiats :",Session.font_size_px(18)))
			for c: Array in p.clues:
				box.add_child(UiFactory.make_label(str(p.labels[int(c[1])])+ (" → " if c[0]=="right" else " ↓ ")+str(p.labels[int(c[2])]),Session.font_size_px(18)))
		"slide":
			box.add_child(UiFactory.make_label("Sélection : "+ (str(p.bars[selected].name) if selected>=0 else "touchez une pièce")))
			var row := _row(box)
			var horizontal: bool = selected < 0 or p.bars[selected].axis == "h"
			row.add_child(UiFactory.make_button("←" if horizontal else "↑",func(): _apply({"a":selected,"b":-1})))
			row.add_child(UiFactory.make_button("→" if horizontal else "↓",func(): _apply({"a":selected,"b":1})))
		"packing":
			for i in range(p.pieces.size()):
				box.add_child(UiFactory.make_button("%d — %s%s" % [i+1,p.labels[i]," (sélectionné)" if i==selected else ""],_select_piece.bind(i)))
			var row := _row(box)
			row.add_child(UiFactory.make_button("Tourner ↻",_rotate_piece))
			row.add_child(UiFactory.make_button("Retirer",func(): _apply({"a":selected,"placement":[-1,-1,piece_turn]})))
		"light":
			box.add_child(UiFactory.make_button("Allumer / éteindre la lanterne",_toggle_light))
		"fold":
			for i in range(p.lengths.size()):
				box.add_child(UiFactory.make_button("Segment %d · longueur %d · %s ↻" % [i+1,int(p.lengths[i]),["→","↓","←","↑"][int(_state().turns[i])]],_apply.bind({"a":i})))
		"supports":
			var grid := GridContainer.new()
			grid.columns = 3
			grid.add_theme_constant_override("h_separation",24)
			grid.add_theme_constant_override("v_separation",24)
			box.add_child(grid)
			for i in range(1,int(p.span)):
				var button := UiFactory.make_button("%d %s" % [i,"×" if Rules.has_number(p.forbidden,i) else ("▲" if Rules.has_number(_state().chosen,i) else "·")],_apply.bind({"a":i}))
				button.disabled = Rules.has_number(p.forbidden,i)
				grid.add_child(button)
		"ferry":
			box.add_child(UiFactory.make_button("Traverser avec la sélection →" if int(_state().boat)==0 else "← Revenir avec la sélection",_sail))
		"gauges":
			for i in range(1,4):
				var row := _row(box)
				row.add_child(UiFactory.make_button("Bande %d ↓" % (i+1),_apply.bind({"a":i,"b":-1})))
				row.add_child(UiFactory.make_button("Bande %d ↑" % (i+1),_apply.bind({"a":i,"b":1})))

func _instructions() -> String:
	match str(_contract().kind):
		"facades": return "Touchez deux bâtiments pour les échanger. Une flèche signifie voisin immédiat dans la direction indiquée. La rivière est en bas du socle."
		"slide": return "Touchez une pièce puis utilisez les flèches. Les rainures imposent son axe ; aucun séparateur ne peut sortir. Amenez la chemise à l'ouverture à droite."
		"packing": return "Sélectionnez un lot. Tourner modifie son orientation ; touchez ensuite sa case d'ancrage en haut à gauche. Les lots ne peuvent pas se chevaucher. Retirer remet un lot sur la table."
		"ropes": return "Touchez deux taquets libres pour les échanger. Les cordages peuvent se rejoindre au même taquet, mais ne doivent pas se croiser ou traverser un autre taquet."
		"pour": return "Touchez une source puis une destination. On verse jusqu'à vider la source ou remplir la destination. Il n'y a ni robinet ni évacuation."
		"light": return "Touchez un miroir pour le tourner. Allumer montre le trajet actuel. Les trois cercles sont des repères à traverser, la flèche de gauche en bas est le quai."
		"fold": return "Chaque bouton oriente un segment vers droite, bas, gauche ou haut. Le dessin s'arrête au premier obstacle. Les segments ne peuvent ni se croiser ni sortir du logement."
		"supports": return "Les positions 0 et 10 sont des culées fixes. Choisissez trois appuis. Les charges lourdes doivent être au-dessus d'un appui ; deux appuis successifs ne peuvent être séparés de plus de trois intervalles."
		"ferry": return "Touchez les personnes et caisses sur la rive de la navette, puis Traverser. Capacité totale : trois unités. Jo ou Aline doit être à bord. Les caisses peuvent attendre seules."
		"gauges": return "Les boutons déplacent les bandes. Chaque paire de marques portant le même chiffre représente la même hauteur réelle. La bande de gauche est fixée."
	return ""

func _remember_scroll() -> void:
	var margins := get_child(0) if get_child_count()>0 else null
	if margins != null and margins.get_child_count()>0 and margins.get_child(0) is ScrollContainer:
		scroll_y = margins.get_child(0).scroll_vertical

func _board_pressed(index: int) -> void:
	if puzzle_id in Session.state.campaign.solved: return
	_remember_scroll()
	var p := _contract()
	match str(p.kind):
		"facades","ropes","pour":
			if selected < 0:
				selected=index
			else:
				var a := selected
				selected=-1
				_apply({"a":a,"b":index})
				return
		"slide":
			var cells: Dictionary = Rules.occupancy(p,_state()).cells
			selected=int(cells.get(Vector2i(index%int(p.cols),index/int(p.cols)),-1))
		"packing":
			if selected>=0:
				_apply({"a":selected,"placement":[index%int(p.cols),index/int(p.cols),piece_turn]})
				return
		"light":
			_apply({"a":index})
			return
		"ferry":
			if int(_state().bank[index]) != int(_state().boat):
				feedback="Cet élément attend sur l'autre rive."
			elif index in passengers:
				passengers.erase(index)
			else:
				passengers.append(index)
	_rebuild()

func _select_piece(index: int) -> void:
	_remember_scroll()
	selected=index
	piece_turn=int(_state().placements[index][2])
	scroll_y=0
	_rebuild()

func _rotate_piece() -> void:
	_remember_scroll()
	piece_turn=posmod(piece_turn+1,4)
	feedback="Orientation changée : touchez la case d'ancrage pour poser."
	scroll_y=0
	_rebuild()

func _toggle_light() -> void:
	trace_visible=not trace_visible
	scroll_y=0
	_rebuild()

func _sail() -> void:
	_apply({"crew":passengers.duplicate()})
	passengers.clear()
	_rebuild()

func _apply(action: Dictionary) -> void:
	if puzzle_id in Session.state.campaign.solved or not Session.state.can_enter(puzzle_id): return
	_remember_scroll()
	var result: Dictionary = Rules.act(_contract(),_state(),action)
	if result.get("ok",false):
		previous_state = _state().duplicate(true)
		history.append(_state().duplicate(true))
		if history.size()>100: history.pop_front()
		Session.state.campaign.puzzles[puzzle_id]=result.state
		Session.state.dirty=true
		var saved: Dictionary = Session.save_now()
		feedback="" if saved.get("ok",false) else "Sauvegarde indisponible : gardez le jeu ouvert."
	else:
		feedback=str(result.get("message","Sélectionnez un élément mobile."))
	_rebuild()

func _undo() -> void:
	if puzzle_id in Session.state.campaign.solved: return
	_remember_scroll()
	if not history.is_empty():
		Session.state.campaign.puzzles[puzzle_id]=history.pop_back()
		Session.state.dirty=true
		Session.save_now()
	selected=-1
	passengers.clear()
	feedback=""
	_rebuild()

func _reset() -> void:
	Session.state.reset_unsolved_puzzle(puzzle_id)
	Session.save_now()
	history.clear()
	selected=-1
	passengers.clear()
	feedback=""
	scroll_y=0
	_rebuild()

func _verify() -> void:
	var result: Dictionary = Rules.validate(_contract(),_state())
	if result.valid:
		var resolved: Dictionary = Session.state.resolve_puzzle(puzzle_id)
		if resolved.get("ok",false):
			Session.save_now()
			Session.navigate("s02",false)
	else:
		feedback=result.message
		_remember_scroll()
		_rebuild()
