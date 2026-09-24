extends SceneTree
var failures: Array[String]=[]
var scene: Control
func _init() -> void:call_deferred("run")
func run() -> void:
 var session:=root.get_node("Session")
 var original: Dictionary=session.state.campaign.duplicate(true)
 scene=load("res://scenes/slice/lantern.tscn").instantiate()
 scene.local_path="user://slice-test-"+str(Time.get_ticks_usec())+".cfg"
 root.add_child(scene);current_scene=scene
 await process_frame
 check(scene.modal!=null,"Introduction displayed")
 check(not scene.board.enabled,"Intro blocks manipulation")
 scene.begin()
 scene.reduced=true;scene.board.reduced=true
 await process_frame
 for i in range(6):check(scene.board.mirror_buttons[i].size.x>=144,"48dp touch target")
 scene.board.mirror_buttons[0].pressed.emit()
 check(int(scene.puzzle.turns[0])==1,"Real mirror widget rotates")
 scene.undo()
 check(int(scene.puzzle.turns[0])==0,"Undo restores geometry")
 scene.inspect_mirror(1)
 check(scene.modal!=null and not scene.board.enabled,"Inspection modal blocks board")
 scene._close_modal()
 scene.show_notebook();scene.request_hint()
 check(scene.hints==1,"Progressive hint")
 scene._close_modal()
 scene.toggle_sound();check(scene.audio.muted,"Mute covers all audio")
 scene.toggle_sound()
 for i in [0,1,3]:scene.turn_mirror(i)
 await create_timer(.25).timeout
 check(scene.finished,"Completion from actual gestures")
 check(not scene.board.enabled,"Solved board locked")
 check(scene.reveal>0,"Completion changes lighting")
 check(session.state.campaign==original,"Standalone does not change campaign")
 var config:=ConfigFile.new()
 check(config.load(scene.local_path)==OK,"Slice saves independently")
 check(config.get_value("slice","finished",false),"Completion saved")
 scene.replay()
 check(not scene.finished and scene.puzzle==scene.contract.initial,"Replay resets only slice")
 scene._close_modal()
 # A pending valid animation must not resolve a board changed in the meantime.
 for i in [0,1,3]:scene.turn_mirror(i)
 scene.undo()
 await create_timer(.25).timeout
 check(not scene.finished,"Stale completion canceled by undo")
 scene.queue_free();await process_frame
 for item in failures:push_error(item)
 print("PREMIUM SLICE: ","PASS" if failures.is_empty() else "FAIL")
 quit(0 if failures.is_empty() else 1)
func check(ok: bool,label: String) -> void:
 if not ok:failures.append(label)
