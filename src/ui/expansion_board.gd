extends Control
## Disposable greybox geometry: visible material, marks, occlusion and touch areas.
signal pressed(index: int)
const Rules = preload("res://src/rules/expansion_rules.gd")
const INK := Color("26333c")
const PAPER := Color("f1e8d5")
const BLUE := Color("476d73")
const ACCENT := Color("a86546")
const COLORS := [Color("91a9ac"), Color("c99b7b"), Color("bbc6a0"), Color("d8bf8e"), Color("b4a8c5"), Color("b6b9c0"), Color("b9d4cf"), Color("d9afbd"), Color("cdcf99"), Color("9caed0")]
var contract: Dictionary
var state: Dictionary
var selection := -1
var crew: Array = []
var preview_turn := 0
var regions: Array = []
var trace_visible := false

func configure(p: Dictionary, s: Dictionary, selected: int = -1, passengers: Array = [], rotation: int = 0, trace: bool = false) -> void:
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

func _label(pos: Vector2, text: String, font_size: int = 40, color: Color = INK) -> void:
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _rect(rect: Rect2, color: Color, border: bool = true) -> void:
	draw_rect(rect, color)
	if border: draw_rect(rect, INK, false, 3)

func _hit(rect: Rect2, index: int) -> void:
	regions.append({"rect": rect, "index": index})

func _cell(x: int, y: int, cell: float = 144.0) -> Rect2:
	return Rect2(48 + x * cell, 64 + y * cell, cell, cell)

func _center(x: int, y: int, cell: float = 144.0) -> Vector2:
	return _cell(x,y,cell).get_center()

func _grid(cols: int, rows: int, cell: float = 144.0) -> void:
	for y in range(rows):
		for x in range(cols): _rect(_cell(x,y,cell), Color("e1d7c3"))

func _draw() -> void:
	if contract.is_empty(): return
	regions.clear()
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * size.x / 960.0)
	_rect(Rect2(0,0,960,960), PAPER)
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
		var r := Rect2(24 + (i % 3) * 308, 80 + (i / 3) * 340, 292, 300)
		_rect(r, COLORS[id])
		var house := Rect2(r.position + Vector2(66,65), Vector2(160,120))
		_rect(house, PAPER)
		draw_colored_polygon(PackedVector2Array([house.position, house.position+Vector2(80,-48),house.position+Vector2(160,0)]), INK)
		for w in range(1 + id % 3):
			_rect(Rect2(house.position+Vector2(15+w*42,40),Vector2(26,42)), BLUE)
		_label(r.position+Vector2(12,250), str(contract.labels[id]), 40)
		if i == selection: draw_rect(r.grow(-4), ACCENT, false, 10)
		_hit(r, i)
	_rect(Rect2(24,810,916,70), BLUE, false)
	_label(Vector2(48,858), "Rivière — rangée du bas", 42, PAPER)

func _pieces() -> void:
	var cell := 144.0 if contract.kind == "slide" else 168.0
	_grid(int(contract.cols), int(contract.rows), cell)
	var occupied: Dictionary = Rules.occupancy(contract, state).cells
	for coord: Vector2i in occupied:
		var id := int(occupied[coord])
		_rect(_cell(coord.x,coord.y,cell).grow(-5), COLORS[id % COLORS.size()])
		_label(_cell(coord.x,coord.y,cell).position+Vector2(15,52), str(id+1), 48)
		if id == selection: draw_rect(_cell(coord.x,coord.y,cell).grow(-8), ACCENT, false, 8)
	for y in range(int(contract.rows)):
		for x in range(int(contract.cols)): _hit(_cell(x,y,cell), y*int(contract.cols)+x)
	if contract.kind == "slide":
		_label(Vector2(914,450), "→", 44, ACCENT)
		_label(Vector2(50,966), "1 : chemise à sortir →", 40)
	else:
		if selection >= 0:
			_label(Vector2(48,795), "Lot %d — forme à poser :" % (selection+1), 42)
			for c: Vector2i in Rules.shape(contract.pieces[selection], preview_turn):
				_rect(Rect2(Vector2(500,740)+Vector2(c)*48,Vector2(46,46)), COLORS[selection])
		_label(Vector2(48,920), "Touchez la case du coin haut gauche.", 36)

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
		_rect(rect, COLORS[int(state.order[i])])
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
		var r := Rect2(x, 780-cap*70, 240, cap*70)
		_rect(r, Color("fcf8ee"))
		_rect(Rect2(x+5,780-volume*70,230,volume*70), BLUE, false)
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
		var x := 30.0 if int(state.bank[i]) == 0 else 650.0
		var r := Rect2(x,110+i*176,280,152)
		_rect(r,COLORS[i])
		_label(r.position+Vector2(12,58),str(contract.labels[i]),46)
		_label(r.position+Vector2(12,118),str(int(contract.weights[i]))+" unité(s)",36)
		if i in crew: draw_rect(r.grow(-3),ACCENT,false,10)
		_hit(r,i)
	var boat := Rect2(345 if int(state.boat)==0 else 475,780,140,90)
	_rect(boat,PAPER)
	_label(Vector2(40,945),"Navette : 3 unités ; au moins un secouriste.",38)

func _gauges() -> void:
	for i in range(4):
		var x := 48.0+i*220
		var off := int(state.offsets[i])
		_rect(Rect2(x,80,185,790),Color("e0d5bc"))
		for n in range(6):
			var y := 830.0-(n+off)*70
			draw_line(Vector2(x,y),Vector2(x+185,y),Color("b6ac95"),2)
			_label(Vector2(x+75,y-8),str(n),30)
		_label(Vector2(x+36,940),"Fixe" if i==0 else str(i+1),40)
	for j in range(contract.links.size()):
		var link: Dictionary = contract.links[j]
		for side in ["a","b"]:
			var i := int(link[side])
			var mark := int(link["m"+side])
			var x := 48.0+i*220
			var y := 830.0-(mark+int(state.offsets[i]))*70
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
			pressed.emit(int(region.index))
			accept_event()
			return
