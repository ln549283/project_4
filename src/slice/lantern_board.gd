extends Control
signal turned(index: int)
signal inspected(index: int)
signal touched
const Rules=preload("res://src/rules/expansion_rules.gd")
const BRASS=Color("b99457")
const PAPER=Color("e9dbb7")
var contract: Dictionary
var state: Dictionary
var angles: Array[float]=[]
var lifts: Array[float]=[]
var mirror_buttons: Array[Button]=[]
var texture: Texture2D
var trace: Dictionary={"path":[],"marks":0,"valid":false}
var beam := 0.0
var clock := 0.0
var enabled := false
var reduced := false
var held := -1
var held_time := 0.0
var suppress_click := false
var selected := -1
var light_tween: Tween
var turns_tweens: Dictionary={}
var border: StyleBoxFlat
func configure(p: Dictionary,s: Dictionary) -> void:
 contract=p
 state=s.duplicate(true)
 texture=load("res://assets/slice/lantern/mirror.webp")
 for i in range(6):
  angles.append(_angle(i))
  lifts.append(0.0)
func _ready() -> void:
 name="LanternBoard"
 size=Vector2(888,888)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 border=StyleBoxFlat.new()
 border.bg_color=Color("142b30")
 border.border_color=Color("8a6b40")
 border.set_border_width_all(3)
 border.set_corner_radius_all(24)
 border.shadow_size=24
 border.shadow_offset=Vector2(0,16)
 border.shadow_color=Color(0,0,0,.65)
 for i in range(6):
  var b:=Button.new()
  b.name="Mirror%d"%i
  b.position=cell(contract.mirrors[i])-Vector2(74,74)
  b.size=Vector2(148,148)
  b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
  b.tooltip_text="Miroir %d · toucher : tourner · maintenir : examiner"%(i+1)
  b.accessibility_name="Miroir %d, tourner"%(i+1)
  for key in ["normal","hover","pressed","disabled"]:b.add_theme_stylebox_override(key,StyleBoxEmpty.new())
  var focus:=StyleBoxFlat.new()
  focus.bg_color=Color(0,0,0,0)
  focus.border_color=PAPER
  focus.set_border_width_all(3)
  focus.set_corner_radius_all(74)
  b.add_theme_stylebox_override("focus",focus)
  b.button_down.connect(_down.bind(i))
  b.button_up.connect(_up)
  b.pressed.connect(_click.bind(i))
  b.focus_entered.connect(func():selected=i;queue_redraw())
  b.mouse_entered.connect(func():selected=i;queue_redraw())
  b.mouse_exited.connect(func():selected=-1;queue_redraw())
  mirror_buttons.append(b)
  add_child(b)
 update_state(state,false)
func cell(p: Variant) -> Vector2:
 return Vector2(134+float(p[0])*124,134+float(p[1])*124)
func _angle(i: int) -> float:
 return -PI/4.0 if int(state.turns[i])==0 else PI/4.0
func _down(i: int) -> void:
 if not enabled:return
 held=i;held_time=0.0;suppress_click=false
 lifts[i]=1.0
 touched.emit()
func _up() -> void:
 if held>=0:lifts[held]=0.0
 held=-1
func _click(i: int) -> void:
 if not enabled or suppress_click:return
 turned.emit(i)
func update_state(s: Dictionary,animate: bool=true) -> void:
 state=s.duplicate(true)
 trace=Rules.light_trace(contract,state)
 for i in range(angles.size()):
  if turns_tweens.has(i) and turns_tweens[i].is_valid():turns_tweens[i].kill()
  if animate and not reduced:
   var tw:=create_tween()
   turns_tweens[i]=tw
   tw.tween_method(func(v: float):angles[i]=v,_safe_angle(angles[i]),_angle(i),.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  else:angles[i]=_angle(i)
 if light_tween!=null and light_tween.is_valid():light_tween.kill()
 beam=0.0 if animate and not reduced else 1.0
 if animate and not reduced:light_tween=create_tween();light_tween.tween_property(self,"beam",1.0,.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 queue_redraw()
func _safe_angle(value: float) -> float:return value
func _process(delta: float) -> void:
 if not reduced:clock+=delta
 if held>=0 and enabled:
  held_time+=delta
  if held_time>.5:
   suppress_click=true
   var i:=held
   _up()
   inspected.emit(i)
 queue_redraw()
func set_enabled(value: bool) -> void:
 enabled=value
 for b in mirror_buttons:b.disabled=not value
func _draw() -> void:
 if border==null:return
 draw_style_box(border,Rect2(0,0,888,888))
 # Physical frame: inset brass edge, a dark engraved groove, fine grain.
 draw_rect(Rect2(22,22,844,844),Color("4c5140"),false,1.0,true)
 draw_rect(Rect2(29,29,830,830),Color("091c22"),false,3.0,true)
 for i in range(52):
  var y:=42.0+i*15.5
  draw_line(Vector2(38,y),Vector2(850,y+sin(i*.7)*3),Color(.46,.64,.56,.024),1,true)
 for x in range(7):
  draw_line(Vector2(72+x*124,72),Vector2(72+x*124,816),Color(.64,.68,.5,.08),1,true)
  draw_line(Vector2(72,72+x*124),Vector2(816,72+x*124),Color(.64,.68,.5,.08),1,true)
 for x in range(6):
  for y in range(6):draw_circle(cell([x,y]),2,Color(.64,.68,.5,.23))
 for pos in [Vector2(16,16),Vector2(872,16),Vector2(16,872),Vector2(872,872)]:
  draw_circle(pos,4,BRASS.darkened(.3));draw_line(pos-Vector2(2,2),pos+Vector2(2,2),Color("1b2727"),1,true)
 var points: Array=trace.path
 for mark in contract.marks:
  var pos:=cell(mark)
  var lit:=false
  for j in range(int(points.size()*beam)):
   if points[j]==Vector2i(int(mark[0]),int(mark[1])):lit=true
  if lit:halo(pos,46,Color(1,.69,.28,.12))
  draw_arc(pos,18,0,TAU,40,PAPER if lit else BRASS.darkened(.18),2,true)
  var diamond:=PackedVector2Array([pos+Vector2(0,-10),pos+Vector2(7,0),pos+Vector2(0,10),pos+Vector2(-7,0)])
  draw_colored_polygon(diamond,PAPER if lit else Color("55655b"))
 # A continuous ray, stopped precisely at the physical board rim.
 var count:=maxi(0,points.size()-1)
 var visible_length:=beam*float(count)
 for j in range(count):
  if float(j)>=visible_length:break
  var a:=_clipped_cell(points[j])
  var b:=a.lerp(_clipped_cell(points[j+1]),clampf(visible_length-float(j),0,1))
  for width in [24,14,7]:draw_line(a,b,Color(1,.62,.23,.035 if width==24 else .08),width,true)
  draw_line(a,b,Color(1,.82,.43,.94),2.5,true)
  draw_line(a,b,Color(1,.98,.82,.92),1,true)
 # Input and quay ports have distinct silhouettes, never color alone.
 var source:=Vector2(12,258)
 halo(source,44,Color(1,.56,.15,.14))
 draw_circle(source,12,Color("e4b368"))
 draw_circle(source,5,PAPER)
 var target:=Vector2(12,506)
 var arrived: bool=bool(trace.valid) and beam>.99
 if arrived:halo(target,60,Color(1,.75,.4,.18))
 draw_arc(target,17,-PI/2,PI/2,28,PAPER if arrived else BRASS,3,true)
 draw_line(target+Vector2(-5,-14),target+Vector2(-5,14),BRASS,3,true)
 for i in range(6):
  var pos:=cell(contract.mirrors[i])
  var lift: float=lifts[i]
  draw_circle(pos+Vector2(2,9+lift*4),61,Color(0,0,0,.33))
  if i==selected or held==i:draw_arc(pos,71,0,TAU,64,Color(.93,.78,.45,.65),1.5,true)
  draw_set_transform(pos-Vector2(0,lift*7),angles[i],Vector2.ONE*(1.0+lift*.04))
  draw_texture_rect(texture,Rect2(-68,-68,136,136),false)
  draw_set_transform(Vector2.ZERO)
 # Engraving is intentionally small, decorative, never an instruction.
 var font:=ThemeDB.fallback_font
 draw_string(font,Vector2(322,855),"ATELIER  ·  ÉTUDE DE LUMIÈRE",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a39472"))
func _clipped_cell(p: Variant) -> Vector2:
 var v:=cell(p)
 return Vector2(clampf(v.x,12,876),clampf(v.y,12,876))
func halo(pos: Vector2,radius: float,color: Color) -> void:
 for i in range(8,0,-1):
  var c:=color;c.a*=pow(1.0-float(i)/9.0,2)
  draw_circle(pos,radius*float(i)/8,c)
