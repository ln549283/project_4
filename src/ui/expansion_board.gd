extends Control
## Physical workshop board; exact geometry and hit areas remain contract-driven.
signal pressed(index: int)
const Art = preload("res://src/presentation/production_art.gd")
const Rules = preload("res://src/rules/expansion_rules.gd")
const INK := Color("eadfc8")
const PAPER := Color("142d32")
const BLUE := Color("476d73")
const ACCENT := Color("dfb775")
const COLORS := [Color("426166"), Color("785344"), Color("576046"), Color("74613e"), Color("60566c"), Color("53626c"), Color("3f665e"), Color("735c60"), Color("676943"), Color("485b73")]
const BOARD_TEXTURE = preload("res://assets/slice/lantern/board.webp")
const BUILDINGS = preload("res://assets/production/buildings.webp")
var previous: Dictionary = {}
var movement := 1.0

var contract: Dictionary
var state: Dictionary
var selection := -1
var crew: Array = []
var preview_turn := 0
var regions: Array = []
var trace_visible := false

func configure(p: Dictionary, s: Dictionary, selected: int = -1, passengers: Array = [], rotation: int = 0, trace: bool = false, old_state: Dictionary = {}) -> void:
	previous = old_state
	contract = p
	state = s
	selection = selected
	crew = passengers
	preview_turn = rotation
	trace_visible = trace
	custom_minimum_size = Vector2(0, 1000)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _ready() -> void:
	if not previous.is_empty() and not bool(Session.settings.reduced_motion):
		movement = 0.0
		create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_method(_animate, 0.0, 1.0, 0.32)

func _animate(value: float) -> void:
	movement = value
	queue_redraw()

func _label(pos: Vector2, text: String, font_size: int = 40, color: Color = INK) -> void:
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _rect(rect: Rect2, color: Color, border: bool = true) -> void:
	draw_rect(Rect2(rect.position + Vector2(0,6), rect.size), Color(0,0,0,0.3))
	draw_rect(rect, color)
	if border:
		draw_rect(rect, Color("728079"), false, 2)
		draw_line(rect.position + Vector2(3,3), Vector2(rect.end.x-3,rect.position.y+3), Color(1,0.86,0.65,0.2), 2, true)

func _hit(rect: Rect2, index: int) -> void:
	regions.append({"rect": rect, "index": index})

func _cell(x: int, y: int, cell: float = 144.0) -> Rect2:
	return Rect2(48 + x * cell, 64 + y * cell, cell, cell)

func _center(x: int, y: int, cell: float = 144.0) -> Vector2:
	return _cell(x,y,cell).get_center()

func _grid(cols: int, rows: int, cell: float = 144.0) -> void:
	for y in range(rows):
		for x in range(cols): _rect(_cell(x,y,cell), Color("183339"))

func _draw() -> void:
	if contract.is_empty(): return
	regions.clear()
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * size.x / 960.0)
	draw_texture_rect(BOARD_TEXTURE, Rect2(0,0,960,1000), false)
	match str(contract.kind):
		"facades": _facades()
		"slide", "packing": _pieces()
		"ropes": _ropes()
		"pour": _pour()
		"light": _light()
		"fold": _fold()
		"supports": _supports()
		"ferry": _ferry()
		"gauges": _gauges()

func _facades() -> void:
	for i in range(6):
		var id := int(state.order[i])
		var destination := Vector2(24 + (i % 3) * 308, 80 + (i / 3) * 340)
		var old_index := i
		if previous.has("order"): old_index = Rules.index_of(previous.order, id)
		var origin := Vector2(24 + (old_index % 3) * 308, 80 + (old_index / 3) * 340)
		var pos := origin.lerp(destination, movement)
		if i == selection: pos.y -= 12
		var r := Rect2(pos, Vector2(292,300))
		draw_style_box(_tile_style(i == selection), r)
		var art := Rect2(pos + Vector2(5,0), Vector2(282,248))
		var source := Rect2((id % 3)*512, (id / 3)*512, 512,512)
		draw_texture_rect_region(BUILDINGS, art, source)
		_label(pos+Vector2(12,280), str(contract.labels[id]), 40)
		_hit(Rect2(destination,Vector2(292,300)), i)
	_rect(Rect2(24,810,916,70), BLUE, false)
	_label(Vector2(48,858), "Rivière — rangée du bas", 42, INK)

func _tile_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("25434a") if active else Color(0.06,0.13,0.15,0.7)
	style.border_color = ACCENT if active else Color("64756b")
	style.set_border_width_all(3 if active else 1)
	style.set_corner_radius_all(7)
	style.shadow_color = Color(0,0,0,0.4)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0,5)
	return style

func _pieces() -> void:
	var cell := 144.0 if contract.kind == "slide" else 168.0
	_grid(int(contract.cols), int(contract.rows), cell)
	if contract.kind == "slide":
		for id in range(contract.bars.size()):
			var bar: Dictionary = contract.bars[id]
			var pos := lerpf(float(previous.get("positions",state.positions)[id]),float(state.positions[id]),movement)
			var r := Rect2(48+pos*cell,64+int(bar.lane)*cell,int(bar.length)*cell,cell) if bar.axis == "h" else Rect2(48+int(bar.lane)*cell,64+pos*cell,cell,int(bar.length)*cell)
			r = r.grow(-7)
			draw_style_box(_tile_style(id == selection),r)
			if id == 0: Art.paint(self,11,r.grow(-8))
			else: draw_texture_rect_region(Art.PROPS,r,Rect2(406,465,266,130),Color(0.8,0.9,0.88))
			_label(r.position+Vector2(12,48),str(bar.name),36)
	else:
		var occupied: Dictionary = Rules.occupancy(contract,state).cells
		for coord: Vector2i in occupied:
			var id := int(occupied[coord])
			var r := _cell(coord.x,coord.y,cell).grow(-5)
			_rect(r,COLORS[id])
			Art.paint(self,10 if id == 0 else 0,r.grow(-8))
			_label(r.position+Vector2(8,42),str(id+1),36)
			if id == selection: draw_rect(r.grow(-3),ACCENT,false,5)
	for y in range(int(contract.rows)):
		for x in range(int(contract.cols)): _hit(_cell(x,y,cell), y*int(contract.cols)+x)
	if contract.kind == "slide":
		_label(Vector2(914,450),"→",44,ACCENT)
		_label(Vector2(50,966),"Chemise : sortie à droite →",40)
	else:
		if selection >= 0:
			_label(Vector2(48,795),"Lot %d — forme à poser :" % (selection+1),42)
			for c: Vector2i in Rules.shape(contract.pieces[selection],preview_turn):
				_rect(Rect2(Vector2(500,740)+Vector2(c)*48,Vector2(46,46)),COLORS[selection])
		_label(Vector2(48,920),"Touchez la case du coin haut gauche.",36)

func _ropes() -> void:
	var positions: Array = []
	for point: Array in contract.points: positions.append(Vector2(108+int(point[0])*180, 192+int(point[1])*180))
	for edge: Array in contract.edges:
		var a: Vector2 = positions[Rules.index_of(state.order,int(edge[0]))]
		var b: Vector2 = positions[Rules.index_of(state.order,int(edge[1]))]
		draw_line(a,b,INK,14,true)
		draw_line(a,b,Color("d0b68d"),7,true)
	for i in range(6):
		var pos: Vector2 = positions[i]
		var rect := Rect2(pos-Vector2(76,76),Vector2(152,152))
		Art.paint(self,2,rect)
		_label(pos+Vector2(-18,18), str(int(state.order[i])+1), 54)
		if Rules.has_number(contract.fixed,i):
			_label(pos+Vector2(-55,62), "FIXE", 32)
		if i == selection: draw_rect(rect, ACCENT, false, 10)
		_hit(rect,i)
	_label(Vector2(48,900), "Échanger deux taquets libres.", 44)

func _pour() -> void:
	for i in range(3):
		var x := 36.0 + i*312
		var cap := int(contract.capacities[i])
		var volume := int(state.volumes[i])
		var visual_volume := lerpf(float(previous.get("volumes",state.volumes)[i]), float(volume), movement)
		var r := Rect2(x, 780-cap*70, 240, cap*70)
		Art.paint(self,1,r.grow(24))
		draw_rect(Rect2(x+32,780-visual_volume*65,176,visual_volume*65),Color(0.18,0.43,0.49,0.64))
		draw_line(Vector2(x+32,780-visual_volume*65),Vector2(x+208,780-visual_volume*65),Color("afd2cc"),4,true)
		for n in range(cap+1):
			draw_line(Vector2(x,780-n*70),Vector2(x+30,780-n*70),INK,3)
		_label(Vector2(x,180), "%d / %d L" % [volume,cap],48)
		_label(Vector2(x,850), ["École","Infirmerie","Mesure"][i],40)
		if i == selection: draw_rect(r.grow(10), ACCENT, false, 8)
		_hit(Rect2(x,192,260,620),i)
	_label(Vector2(40,930), "Source, puis destination. Aucun liquide perdu.",36)

func _light() -> void:
	_grid(6,6)
	for mark: Array in contract.marks:
		var pos := _center(int(mark[0]),int(mark[1]))
		draw_circle(pos, 28, BLUE, false, 5, true)
	for i in range(contract.mirrors.size()):
		var m: Array = contract.mirrors[i]
		var r := _cell(int(m[0]),int(m[1]))
		var v := Vector2(42,-42) if int(state.turns[i]) == 0 else Vector2(42,42)
		draw_line(r.get_center()-v,r.get_center()+v,INK,12,true)
		_hit(r,i)
	if trace_visible:
		var trace: Dictionary = Rules.light_trace(contract,state)
		for i in range(trace.path.size()-1):
			var a: Vector2i = trace.path[i]
			var b: Vector2i = trace.path[i+1]
			draw_line(_center(a.x,a.y),_center(b.x,b.y),ACCENT,7,true)
	_label(Vector2(4,278), "→",48,ACCENT)
	_label(Vector2(4,570), "◀",40,BLUE)
	_label(Vector2(50,950), "Lanterne →     Trois cercles → quai ◀",36)

func _fold() -> void:
	_grid(5,5,168)
	for c: Array in contract.blocked:
		var r := _cell(int(c[0]),int(c[1]),168)
		_rect(r, INK)
		_label(r.position+Vector2(54,100), "×",60,PAPER)
	var trace: Dictionary = Rules.fold_trace(contract,state)
	for i in range(trace.path.size()-1):
		var a: Vector2i = trace.path[i]
		var b: Vector2i = trace.path[i+1]
		draw_line(_center(a.x,a.y,168),_center(b.x,b.y,168),ACCENT,20,true)
	var end: Array = contract.target
	draw_circle(_center(int(end[0]),int(end[1]),168),40,BLUE,false,8,true)
	draw_circle(_center(0,0,168),24,INK)
	_label(Vector2(40,950), "Départ ●    Arrivée ○    Montants ×",40)

func _supports() -> void:
	var left := 70.0
	var unit := 80.0
	draw_line(Vector2(left,350),Vector2(left+800,350),INK,18)
	for i in range(11):
		var x := left+i*unit
		_label(Vector2(x-14,310),str(i),36)
		if Rules.has_number(contract.heavy,i):
			_rect(Rect2(x-35,180,70,110),ACCENT)
			_label(Vector2(x-22,260),"↓",54,PAPER)
		if Rules.has_number(state.chosen,i) or i in [0,10]:
			draw_colored_polygon(PackedVector2Array([Vector2(x,360),Vector2(x-30,540),Vector2(x+30,540)]),BLUE)
		if Rules.has_number(contract.forbidden,i):
			_label(Vector2(x-18,590),"×",50,ACCENT)
	_label(Vector2(40,720), "↓ Charge lourde : appui direct",44)
	_label(Vector2(40,792), "× Sol fragile : aucun étai",44)
	_label(Vector2(40,864), "Portée maximale : 3 intervalles",44)
	_label(Vector2(40,936), "Exactement 3 étais mobiles",44)

func _ferry() -> void:
	_rect(Rect2(340,60,280,820),BLUE,false)
	_label(Vector2(35,55),"Départ",46)
	_label(Vector2(675,55),"Halle",46)
	for i in range(4):
		var x := lerpf(30.0 if int(previous.get("bank",state.bank)[i]) == 0 else 650.0,30.0 if int(state.bank[i]) == 0 else 650.0,movement)
		var r := Rect2(x,110+i*176,280,152)
		draw_style_box(_tile_style(i in crew),r)
		Art.paint(self,6+i if i<2 else (0 if i==2 else 10),Rect2(r.position+Vector2(150,4),Vector2(125,142)))
		_label(r.position+Vector2(12,58),str(contract.labels[i]),38)
		_label(r.position+Vector2(12,118),str(int(contract.weights[i]))+" u.",34)
		if i in crew: draw_rect(r.grow(-3),ACCENT,false,10)
		_hit(r,i)
	var boat := Rect2(lerpf(345.0 if int(previous.get("boat",state.boat))==0 else 475.0,345.0 if int(state.boat)==0 else 475.0,movement),770,140,130)
	Art.paint(self,3,boat)
	_label(Vector2(40,945),"Navette : 3 unités ; au moins un secouriste.",38)

func _gauges() -> void:
	for i in range(4):
		var x := 48.0+i*220
		var off := lerpf(float(previous.get("offsets",state.offsets)[i]),float(state.offsets[i]),movement)
		_rect(Rect2(x,80,185,790),Color("3b4b49"))
		for n in range(6):
			var y := 830.0-(n+off)*70
			draw_line(Vector2(x,y),Vector2(x+185,y),Color("7a8170"),2)
			_label(Vector2(x+75,y-8),str(n),30)
		_label(Vector2(x+36,940),"Fixe" if i==0 else str(i+1),40)
	for j in range(contract.links.size()):
		var link: Dictionary = contract.links[j]
		for side in ["a","b"]:
			var i := int(link[side])
			var mark := int(link["m"+side])
			var x := 48.0+i*220
			var y := 830.0-(mark+lerpf(float(previous.get("offsets",state.offsets)[i]),float(state.offsets[i]),movement))*70
			draw_line(Vector2(x,y),Vector2(x+185,y),COLORS[j],14)
			_label(Vector2(x+6,y-18),str(j+1),48,INK)

func _gui_input(event: InputEvent) -> void:
	var point: Vector2
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		point = event.position
	else:
		return
	point *= 960.0 / size.x
	for region: Dictionary in regions:
		if (region.rect as Rect2).has_point(point):
			if Session.presentation_audio != null: Session.presentation_audio.touch()
			pressed.emit(int(region.index))
			accept_event()
			return
