extends Control
const Rules=preload("res://src/rules/expansion_rules.gd")
const BoardScript=preload("res://src/slice/lantern_board.gd")
const AudioScript=preload("res://src/slice/lantern_audio.gd")
const TITLE=preload("res://assets/slice/lantern/title.ttf")
const INK=Color("101f25")
const CREAM=Color("f1e5c9")
const GOLD=Color("d8b777")
@export var campaign_mode := false
var canvas: Control
var background: TextureRect
var board: Control
var audio: Node
var hud: Control
var modal: Control
var status: Label
var subtitle: Label
var counter: Label
var sound_button: Button
var motion_button: Button
var contract: Dictionary
var puzzle: Dictionary
var history: Array[Dictionary]=[]
var begun := false
var finished := false
var reduced := false
var clock := 0.0
var revision := 0
var hints := 0
var target_drift := Vector2.ZERO
var drift := Vector2.ZERO
var local_path := "user://lantern_slice_v1.cfg"
var capture_mode := false
var reveal := 0.0
var modal_tween: Tween
var prior_marks := 0
var save_error := false
var previous_aspect := Window.CONTENT_SCALE_ASPECT_KEEP
func _ready() -> void:
 previous_aspect=get_window().content_scale_aspect
 get_window().content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
 contract=Session.state.puzzles_contract.p13
 puzzle=contract.initial.duplicate(true)
 reduced=bool(Session.settings.get("reduced_motion",false))
 if campaign_mode:
  if not Session.state.can_enter("p13"):
   Session.navigate("s02",false)
   return
  puzzle=Session.state.campaign.puzzles.p13.duplicate(true)
  hints=int(Session.state.campaign.hints.p13)
  finished="p13" in Session.state.campaign.solved
 else:_load_local()
 var matte:=ColorRect.new();matte.color=INK;matte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);matte.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(matte)
 canvas=Control.new()
 canvas.name="Stage"
 canvas.size=Vector2(1080,1920)
 add_child(canvas)
 resized.connect(_fit)
 _fit()
 background=TextureRect.new()
 background.texture=preload("res://assets/slice/lantern/atelier.webp")
 background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 background.size=Vector2(1080,1920)
 background.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var material:=ShaderMaterial.new()
 material.shader=preload("res://src/slice/atelier.gdshader")
 background.material=material
 canvas.add_child(background)
 # Header/footer contrast is baked as translucent gradients, not a full-screen wash.
 _veil(Rect2(0,0,1080,360),Color(0.025,.055,.07,.78),Color(0,0,0,0))
 _veil(Rect2(0,1640,1080,280),Color(0,0,0,0),Color(.02,.045,.055,.92))
 board=BoardScript.new()
 board.configure(contract,puzzle)
 board.position=Vector2(96,770)
 board.reduced=reduced
 board.turned.connect(turn_mirror)
 board.inspected.connect(inspect_mirror)
 board.touched.connect(func():audio.play_cue("touch"))
 canvas.add_child(board)
 audio=AudioScript.new()
 canvas.add_child(audio)
 hud=Control.new();hud.size=Vector2(1080,1920);hud.mouse_filter=Control.MOUSE_FILTER_IGNORE
 canvas.add_child(hud)
 var back:=_button("‹",Rect2(30,28,148,144),leave,false)
 back.accessibility_name="Retour à l'accueil";hud.add_child(back)
 var eyebrow:=_label("LES RIVES PLIÉES",Rect2(220,66,640,44),27,GOLD)
 eyebrow.add_theme_constant_override("outline_size",2);hud.add_child(eyebrow)
 hud.add_child(_label("La lanterne du quai",Rect2(140,138,800,100),61,CREAM,true))
 subtitle=_label("Une lumière pour retrouver la rive.",Rect2(130,251,820,70),36,CREAM)
 hud.add_child(subtitle)
 sound_button=_button("Son",Rect2(898,28,152,144),toggle_sound,false)
 hud.add_child(sound_button)
 counter=_label("◇  ◇  ◇",Rect2(330,612,420,58),42,GOLD)
 hud.add_child(counter)
 status=_label("Reliez les trois repères, puis le quai.",Rect2(120,685,840,66),36,CREAM)
 hud.add_child(status)
 hud.add_child(_button("Annuler",Rect2(70,1690,280,144),undo,false))
 hud.add_child(_button("Carnet",Rect2(400,1690,280,144),show_notebook,false))
 motion_button=_button("Mouvement",Rect2(730,1690,280,144),toggle_motion,false)
 hud.add_child(motion_button)
 hud.add_child(_label("TOUCHER · TOURNER   /   MAINTENIR · EXAMINER",Rect2(70,1840,940,38),27,Color("b8b7a8")))
 _refresh_controls()
 if finished:
  begun=true;reveal=1;board.set_enabled(false);_show_ending()
 else:_show_intro()
func _fit() -> void:
 if canvas==null:return
 var factor:=minf(size.x/1080.0,size.y/1920.0)
 canvas.scale=Vector2.ONE*factor
 canvas.position=(size-Vector2(1080,1920)*factor)*.5
func _veil(rect: Rect2,top: Color,bottom: Color) -> void:
 var gradient:=Gradient.new();gradient.colors=PackedColorArray([top,bottom])
 var tex:=GradientTexture2D.new();tex.gradient=gradient;tex.fill_from=Vector2(0,0);tex.fill_to=Vector2(0,1)
 var view:=TextureRect.new();view.texture=tex;view.position=rect.position;view.size=rect.size;view.mouse_filter=Control.MOUSE_FILTER_IGNORE
 canvas.add_child(view)
func _label(text: String,rect: Rect2,px: int,color: Color=CREAM,serif: bool=false) -> Label:
 var label:=Label.new();label.text=text;label.position=rect.position;label.size=rect.size
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.add_theme_font_size_override("font_size",px)
 label.add_theme_color_override("font_color",color)
 if serif:label.add_theme_font_override("font",TITLE)
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 return label
func _button(text: String,rect: Rect2,callback: Callable,filled: bool=true) -> Button:
 var b:=Button.new();b.text=text;b.position=rect.position;b.size=rect.size;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 b.add_theme_font_size_override("font_size",42 if text!="‹" else 62)
 for key in ["normal","hover","pressed","focus"]:
  var style:=StyleBoxFlat.new()
  style.bg_color=Color("d7b777") if filled else Color(.035,.09,.105,.0)
  if key=="pressed":style.bg_color=style.bg_color.darkened(.18)
  if key=="hover":style.bg_color=style.bg_color.lightened(.1)
  style.set_corner_radius_all(12)
  style.set_border_width_all(2 if key=="focus" else (1 if filled else 0))
  style.border_color=CREAM if key=="focus" else Color(.71,.6,.4,.45)
  b.add_theme_stylebox_override(key,style)
 b.add_theme_color_override("font_color",INK if filled else CREAM)
 b.add_theme_color_override("font_hover_color",INK if filled else CREAM)
 b.add_theme_color_override("font_pressed_color",INK if filled else CREAM)
 b.pressed.connect(callback)
 return b
func _new_modal() -> Control:
 if modal_tween!=null and modal_tween.is_valid():modal_tween.kill()
 if modal!=null:modal.queue_free()
 hud.visible=false
 board.visible=false
 modal=Control.new();modal.size=Vector2(1080,1920);canvas.add_child(modal)
 var shade:=ColorRect.new();shade.color=Color(.01,.025,.035,.78);shade.size=modal.size
 modal.add_child(shade)
 modal.add_child(_button("‹",Rect2(30,28,148,144),func():
  if begun and not finished:_close_modal()
  else:leave()
 ,false))
 modal.modulate.a=0
 modal_tween=create_tween();modal_tween.tween_property(modal,"modulate:a",1.0,.08 if reduced else .28)
 board.set_enabled(false)
 return modal
func _close_modal() -> void:
 if modal==null:return
 if modal_tween!=null and modal_tween.is_valid():modal_tween.kill()
 var old: Control=modal;modal=null
 old.mouse_filter=Control.MOUSE_FILTER_IGNORE
 old.queue_free()
 hud.visible=true
 board.visible=true
 board.set_enabled(begun and not finished)
func _show_intro() -> void:
 var m:=_new_modal()
 m.add_child(_label("ÉTUDE DE LUMIÈRE",Rect2(130,500,820,60),27,GOLD))
 m.add_child(_label("La nuit n’efface\npas les chemins.",Rect2(120,600,840,230),68,CREAM,true))
 m.add_child(_label("Dans l’atelier, les notes d’Aline révèlent comment la lumière guidait les secours jusqu’au quai.",Rect2(180,880,720,220),44))
 m.add_child(_label("Touchez pour tourner un miroir.\nMaintenez pour l’examiner.\nReliez les trois repères ◇ au quai.",Rect2(170,1140,740,200),42,Color("d0c8b3")))
 m.add_child(_button("Entrer dans l’atelier",Rect2(230,1460,620,144),begin))
func begin() -> void:
 begun=true
 audio.start()
 _close_modal()
 board.modulate.a=0
 var tween:=create_tween()
 tween.tween_property(board,"modulate:a",1.0,.08 if reduced else .65)
 if not reduced:
  board.position.y=792
  tween.parallel().tween_property(board,"position:y",770.0,.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 _refresh_status()
 _schedule_completion()
func turn_mirror(index: int) -> void:
 if not begun or finished or modal!=null or index<0 or index>=6:return
 var result: Dictionary=Rules.act(contract,puzzle,{"a":index})
 if not result.ok:return
 history.append(puzzle.duplicate(true))
 if history.size()>64:history.pop_front()
 puzzle=result.state
 revision+=1
 _persist()
 board.update_state(puzzle,true)
 audio.play_cue("mirror_%d"%(revision%3))
 if bool(Session.settings.get("vibration",false)) and OS.has_feature("mobile"):Input.vibrate_handheld(12)
 _refresh_status()
 _schedule_completion()
func _schedule_completion() -> void:
 var token:=revision
 if not Rules.validate(contract,puzzle).valid:return
 await get_tree().create_timer(.08 if reduced else .85).timeout
 if not is_inside_tree() or token!=revision or finished or not begun:return
 if not Rules.validate(contract,puzzle).valid:return
 finished=true
 board.set_enabled(false)
 if campaign_mode:
  var resolved: Dictionary=Session.state.resolve_puzzle("p13")
  if not resolved.ok:finished=false;status.text="La progression n’a pas pu être enregistrée.";board.set_enabled(true);return
 _persist()
 audio.play_cue("arrival")
 status.text="Le quai est éclairé."
 var tween:=create_tween()
 tween.tween_property(self,"reveal",1.0,.08 if reduced else 1.6)
 await get_tree().create_timer(.12 if reduced else 1.9).timeout
 if is_inside_tree():_show_ending()
func undo() -> void:
 if finished or history.is_empty() or modal!=null:return
 puzzle=history.pop_back();revision+=1
 board.update_state(puzzle,true);_persist();_refresh_status();audio.play_cue("mirror_0")
func _refresh_status() -> void:
 var ray: Dictionary=Rules.light_trace(contract,puzzle)
 var count: int=int(ray.marks)
 counter.text=" ".join(["◆" if count>0 else "◇","◆" if count>1 else "◇","◆" if count>2 else "◇"])
 status.text="%d / 3 repères · rejoignez le quai"%count
 if save_error:status.text="Sauvegarde indisponible · gardez le jeu ouvert."
 if count>prior_marks and begun:audio.play_cue("mark")
 prior_marks=count
func inspect_mirror(index: int) -> void:
 if finished or modal!=null:return
 var m:=_new_modal()
 m.add_child(_label("L’INSTRUMENT D’ALINE",Rect2(140,370,800,60),28,GOLD))
 var sprite:=TextureRect.new();sprite.texture=preload("res://assets/slice/lantern/mirror.webp");sprite.position=Vector2(280,480);sprite.size=Vector2(520,520);sprite.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;sprite.mouse_filter=Control.MOUSE_FILTER_IGNORE
 sprite.pivot_offset=Vector2(260,260);sprite.rotation=-PI/4 if int(puzzle.turns[index])==0 else PI/4
 m.add_child(sprite)
 if not reduced:
  sprite.position=board.position+board.cell(contract.mirrors[index])-Vector2(260,260)
  sprite.scale=Vector2.ONE*.26
  var lift:=create_tween().set_parallel(true)
  lift.tween_property(sprite,"position",Vector2(280,480),.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  lift.tween_property(sprite,"scale",Vector2.ONE,.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 m.add_child(_label("Un quart de tour",Rect2(150,1080,780,100),62,CREAM,true))
 m.add_child(_label("Le laiton pivote, le reflet change.\nChaque miroir dévie la lumière\nà angle droit.",Rect2(150,1220,780,190),44))
 m.add_child(_button("Reposer le miroir",Rect2(230,1520,620,144),_close_modal))
func show_notebook() -> void:
 if modal!=null or finished:return
 _notebook_page()
func _notebook_page() -> void:
 var m:=_new_modal()
 m.add_child(_label("LE CARNET D’ALINE",Rect2(130,400,820,60),28,GOLD))
 m.add_child(_label("Suivre la lumière",Rect2(120,510,840,110),62,CREAM,true))
 m.add_child(_label("« Trois repères, puis la rive.\nCe n’est pas la distance qui compte,\nmais ce que la lumière traverse. »",Rect2(140,675,800,240),44))
 var hint_text: String="Observez le trajet depuis la lanterne.\nUn toucher fait pivoter un miroir."
 if hints>0:hint_text=str(contract.hints[mini(hints,3)-1])
 m.add_child(_label(hint_text,Rect2(160,1000,760,240),36,Color("d9caab")))
 if hints<3:m.add_child(_button("Indice %d / 3"%(hints+1),Rect2(230,1320,620,144),request_hint,false))
 m.add_child(_button("Refermer le carnet",Rect2(230,1510,620,144),_close_modal))
func request_hint() -> void:
 hints=mini(3,hints+1)
 if campaign_mode:Session.state.set_hint_level("p13",hints)
 _persist();_notebook_page()
func _show_ending() -> void:
 var m:=_new_modal()
 m.add_child(_label("LE QUAI RETROUVÉ",Rect2(130,520,820,60),27,GOLD))
 m.add_child(_label("Quelqu’un avait\npréparé le chemin.",Rect2(110,640,860,230),65,CREAM,true))
 m.add_child(_label("La lumière rejoint la rive.\nAline avait pensé à ceux qui\narriveraient après la tombée de la nuit.",Rect2(160,960,760,220),44))
 m.add_child(_label("Les pièces du passage prennent sens.\nIl reste à reconstituer le sauvetage.",Rect2(160,1220,760,160),33,Color("d3c7ab")))
 m.add_child(_button("Continuer" if campaign_mode else "Quitter l’atelier",Rect2(230,1460,620,144),leave))
 if not campaign_mode:m.add_child(_button("Rejouer cette séquence",Rect2(230,1640,620,144),replay,false))
func replay() -> void:
 revision+=1;finished=false;reveal=0;history.clear();hints=0;puzzle=contract.initial.duplicate(true)
 board.update_state(puzzle,false);_persist();_close_modal();begin()
func toggle_sound() -> void:
 audio.muted=not audio.muted
 audio.apply_levels();_refresh_controls()
func toggle_motion() -> void:
 reduced=not reduced;Session.settings.reduced_motion=reduced;Session.save_settings_now()
 board.reduced=reduced;_refresh_controls()
func _refresh_controls() -> void:
 sound_button.text="Muet" if audio.muted else "Son"
 sound_button.accessibility_name="Activer le son" if audio.muted else "Couper le son"
 motion_button.text="Calme" if reduced else "Mouvement"
func _persist() -> void:
 if capture_mode:return
 if campaign_mode:
  Session.state.campaign.puzzles.p13=puzzle.duplicate(true)
  Session.state.dirty=true
  save_error=not Session.save_now().get("ok",false)
 else:
  var config:=ConfigFile.new()
  config.set_value("slice","turns",puzzle.turns);config.set_value("slice","finished",finished);config.set_value("slice","hints",hints)
  save_error=config.save(local_path)!=OK
 if save_error and status!=null:status.text="Sauvegarde indisponible · gardez cette fenêtre ouverte."
func _load_local() -> void:
 var config:=ConfigFile.new()
 if config.load(local_path)!=OK:return
 var candidate: Dictionary={"turns":config.get_value("slice","turns",contract.initial.turns)}
 if Rules.valid_state(contract,candidate):
  puzzle=candidate
  finished=bool(config.get_value("slice","finished",false)) and Rules.validate(contract,puzzle).valid
  hints=clampi(int(config.get_value("slice","hints",0)),0,3)
func leave() -> void:
 if not is_inside_tree():return
 if campaign_mode and finished:Session.state.acknowledge_narrative("n_p13")
 _persist()
 board.set_enabled(false)
 if reduced:
  Session.navigate("s02" if campaign_mode else "s00",false);return
 var fade:=ColorRect.new();fade.color=Color(0,0,0,0);fade.size=Vector2(1080,1920);canvas.add_child(fade)
 var tween:=create_tween();tween.tween_property(fade,"color:a",1.0,.24)
 tween.parallel().tween_property(audio.music,"volume_db",-80.0,.24)
 tween.parallel().tween_property(audio.ambience,"volume_db",-80.0,.24)
 await tween.finished
 Session.navigate("s02" if campaign_mode else "s00",false)
func _process(delta: float) -> void:
 if background==null:return
 if not reduced:clock+=delta
 drift=drift.lerp(Vector2.ZERO if reduced else target_drift,1.0-exp(-delta*3.0))
 background.material.set_shader_parameter("clock",clock)
 background.material.set_shader_parameter("drift",drift)
 background.material.set_shader_parameter("reveal",reveal)
func _input(event: InputEvent) -> void:
 if event is InputEventMouseMotion and canvas!=null:
  var local: Vector2=(event.position-canvas.position)/canvas.scale
  target_drift=(local/Vector2(1080,1920)-Vector2(.5,.5))*2
 if event.is_action_pressed("ui_cancel"):
  if modal!=null and begun and not finished:_close_modal()
  else:leave()
  get_viewport().set_input_as_handled()

func _exit_tree() -> void:
 get_window().content_scale_aspect=previous_aspect
