class_name Main
extends Spatial

var start_pos : Vector3

var prev_start_pos0 : Vector3
var prev_start_pos1 : Vector3
var start_pos_idx : int = 0

var score : int = 0
var lives : int = 0
var invincible = false

var tiny_expl = preload("res://TinyExplosion.tscn")	
var small_expl = preload("res://SmallExplosion.tscn")	
var big_expl = preload("res://BigExplosion.tscn")	

var time_left : float
var game_over = false
var end_sequence_started = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Globals.DEBUG_START_POS:
		$Player.translation = $StartPosition.translation
	
	start_pos = $Player.translation
	prev_start_pos0 = $Player.translation
	prev_start_pos1 = $Player.translation

	time_left = Globals.START_TIME_SECONDS
	$HUD.update_time_label(time_left)
	#$HUD.update_lives_label(1) # todo
	
	self.set_first_person($Player.first_person_mode)
	pass
	

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://IntroScene.tscn")
		return
		
	if game_over:
#		if Input.is_action_just_pressed("primary_fire"):
#			get_tree().change_scene("res://IntroScene.tscn")
		return
		
	time_left -= delta
	if time_left <= 0:
		game_lost()
	pass


func collision(mover, hit):
	if hit.has_method("collided"):
		hit.collided(mover)
	pass


func player_hit():
	player_killed()
	pass
	
	
func player_killed():
	if Globals.PLAYER_INVINCIBLE:
		return
		
	if $Player.alive == false:
		return
	
	if invincible:
		return
		
	$Player.set_first_person_mode(false)
	$Player/Human.anim("Die")

	$Player.alive = false
	self.small_explosion($Player)
	$Player.get_node("Audio_Hit").play()
	if lives > 0:
		$RestartTimer.start()
	else:
		game_lost()
	pass
	
	
func restart_player():
	#todo $HUD.update_lives_label(extra_lives.size()+1)
	
	invincible = true
	$InvincibleTimer.start()
	pass
	

func _on_RestartTimer_timeout():
	$RestartTimer.stop()
	restart_player()
	pass


func tiny_explosion(spatial):
	#var expl = load("res://TinyExplosion.tscn")	
	var i = tiny_expl.instance()
	add_child(i)
	i.translation = spatial.global_transform.origin
	pass
	
	
func small_explosion(spatial):
	#var small_expl = load("res://SmallExplosion.tscn")	
	var i = small_expl.instance()
	add_child(i)
	i.translation = spatial.global_transform.origin
	pass
	
	
func big_explosion(spatial):
	#var big_expl = load("res://BigExplosion.tscn")	
	var i = big_expl.instance()
	add_child(i)
	i.translation = spatial.global_transform.origin
	pass
	

func play_audio(path):
	var s = load(path)
	$AudioStreamPlayer_Generic.stream = s
	$AudioStreamPlayer_Generic.play()
	pass
	

func play_clang():
	$Sounds/AudioBump.play()
	pass
	

func game_lost():
	game_over = true
	$HUD.show_game_over()
	$Sounds/GameOverMusic.play()
	pass
	

func _on_InvincibleTimer_timeout():
	invincible = false
	$InvincibleTimer.stop()
	pass


func sterner_killed():
	$Sounds/VictoryMusic.play()
	$InvincibleTimer.stop()
	invincible = true
	$HUD.show_well_done()
	game_over = true
	pass


func _on_Timer_timeout():
	$AudioAmbience.play()
	pass


func set_first_person(fp : bool):
	$HUD.show_targetter(fp)
	pass
	

func get_patrol_points(droid : Spatial):
	var dest = $SternersHouse.get_rnd_destination();
	var patrol_points = $SternersHouse.get_route(droid.translation, dest);
	return patrol_points


func _on_HudTimer_timeout():
	$HUD.update_time_label(time_left)
	pass # Replace with function body.
