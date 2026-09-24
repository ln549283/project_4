extends Node
const ROOT := "res://assets/slice/lantern/"
var music: AudioStreamPlayer
var ambience: AudioStreamPlayer
var effects: Array[AudioStreamPlayer]=[]
var muted := false
var started := false
var effect_index := 0
func _ready() -> void:
 music=_player("river_theme.ogg",true)
 ambience=_player("river_air.ogg",true)
 for i in range(6):
  var p:=AudioStreamPlayer.new()
  add_child(p)
  effects.append(p)
 apply_levels()
func _player(file: String,loop: bool) -> AudioStreamPlayer:
 var p:=AudioStreamPlayer.new()
 var stream: AudioStream=load(ROOT+file)
 if stream is AudioStreamOggVorbis:stream.loop=loop
 p.stream=stream
 add_child(p)
 return p
func start() -> void:
 if started:return
 started=true
 music.play()
 ambience.play()
func apply_levels() -> void:
 if music==null:return
 music.volume_db=-80.0 if muted else linear_to_db(maxf(.001,float(Session.settings.music)))-5.0
 ambience.volume_db=-80.0 if muted else linear_to_db(maxf(.001,float(Session.settings.sfx)))-7.0
 for p in effects:p.volume_db=-80.0 if muted else linear_to_db(maxf(.001,float(Session.settings.sfx)))-6.0
func play_cue(cue: String) -> void:
 if muted:return
 var p: AudioStreamPlayer=effects[effect_index%effects.size()]
 effect_index+=1
 p.stream=load(ROOT+cue+".wav")
 p.pitch_scale=1.0
 p.play()
func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_PAUSED:
  for p in get_children():p.stream_paused=true
 elif what==NOTIFICATION_APPLICATION_RESUMED:
  for p in get_children():p.stream_paused=false
