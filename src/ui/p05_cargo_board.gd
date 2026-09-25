class_name P05CargoBoard
extends Control
signal item_pressed(item_id: String)
signal slot_pressed(index: int)
const Art = preload("res://src/presentation/production_art.gd")
const WOOD = preload("res://assets/slice/lantern/board.webp")
const GOLD := Color("d0b17d")
const TEXT := Color("eadfc8")
var slots: Array = []
var contract: Dictionary = {}
var selected_item := ""
var compare_mode := false
var hits: Array = []

func configure(new_slots: Array, new_contract: Dictionary, new_selected: String, new_compare: bool) -> void:
	slots = new_slots.duplicate()
	contract = new_contract
	selected_item = new_selected
	compare_mode = new_compare
	custom_minimum_size = Vector2(0,1060)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	queue_redraw()

func _label(p: Vector2, text: String, width: float, font_size: int = 38) -> void:
	draw_string(ThemeDB.fallback_font,p,text,HORIZONTAL_ALIGNMENT_CENTER,width,font_size,TEXT)

func _card(r: Rect2, selected: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("2e4849") if selected else Color("142d32")
	style.border_color = GOLD if selected else Color("6a7367")
	style.set_border_width_all(4 if selected else 2)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0,0,0,.4)
	style.shadow_size = 6
	draw_style_box(style,r)

func _draw() -> void:
	if contract.is_empty(): return
	hits.clear()
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE*size.x/960.0)
	draw_texture_rect(WOOD,Rect2(0,0,960,1040),false)
	_label(Vector2(24,70),"BARGE · SIX BERCEAUX",912,38)
	var left := 0
	var right := 0
	for i in range(6):
		var r := Rect2(24+i*152,120,144,240)
		var id := "" if slots[i] == null else str(slots[i])
		_card(r,id == selected_item and not id.is_empty())
		_label(r.position+Vector2(0,48),str(int(contract.positions[i])),144,40)
		if not id.is_empty():
			var mass := int(contract.weights[id])
			_draw_cargo(id,Rect2(r.position+Vector2(12,66),Vector2(120,108)))
			_label(r.position+Vector2(0,218),str(mass)+" unités",144,28)
			if i < 3: left += mass*absi(int(contract.positions[i]))
			else: right += mass*absi(int(contract.positions[i]))
		else:
			draw_rect(Rect2(r.position+Vector2(28,85),Vector2(88,104)),GOLD,false,2)
		hits.append({"rect":r,"slot":i})
	# Equal distances on either side of a fixed pivot; no physics affects the rules.
	draw_line(Vector2(40,390),Vector2(920,390),GOLD,9,true)
	draw_colored_polygon(PackedVector2Array([Vector2(480,392),Vector2(450,440),Vector2(510,440)]),GOLD)
	_label(Vector2(24,490),"Distance au pivot : 3 · 2 · 1  |  1 · 2 · 3",912,36)
	if compare_mode: _label(Vector2(24,544),"Moment gauche %d  ·  Moment droit %d" % [left,right],912,38)
	var keys: Array = contract.weights.keys()
	for i in range(keys.size()):
		var id := str(keys[i])
		if id in slots: continue
		var r := Rect2(24+(i%3)*308,580+(i/3)*218,292,200)
		_card(r,id == selected_item)
		_draw_cargo(id,Rect2(r.position+Vector2(76,6),Vector2(140,108)))
		_label(r.position+Vector2(8,145),str(contract.labels[id]),276,36)
		_label(r.position+Vector2(8,186),"Masse : "+str(int(contract.weights[id])),276,32)
		hits.append({"rect":r,"item":id})

func _draw_cargo(id: String, r: Rect2) -> void:
	var prop: int = {"medicine":10,"food":0,"tools":4,"dye":11,"press":0,"lantern":1}.get(id,0)
	Art.paint(self,prop,r)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var point: Vector2 = event.position * 960.0 / size.x
		for hit: Dictionary in hits:
			if (hit.rect as Rect2).has_point(point):
				if hit.has("slot"): slot_pressed.emit(int(hit.slot))
				else: item_pressed.emit(str(hit.item))
				accept_event()
				return
