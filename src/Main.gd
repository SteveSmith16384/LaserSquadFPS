class_name Main
extends Spatial

var start_pos : Vector3

var prev_start_pos0 : Vector3
var prev_start_pos1 : Vector3
var start_pos_idx : int = 0

var score : int = 0
var invincible = false

var tiny_expl = preload("res://TinyExplosion.tscn")	
var small_expl = preload("res://SmallExplosion.tscn")	
var big_expl = preload("res://BigExplosion.tscn")	

var level;
var extra_lives = []
var time_left : float
var game_over = false
var end_sequence_started = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	level = $Highway

	if Globals.DEBUG_START_POS:
		$Player.translation = $StartPosition.translation
	
	start_pos = $Player.translation
	prev_start_pos0 = $Player.translation
	prev_start_pos1 = $Player.translation

	time_left = Globals.START_TIME_SECONDS
	$HUD.update_time_label(time_left)
	$HUD.update_lives_label(extra_lives.size()+1)
	$HUD.update_score_label(0)
	
	self.set_first_person($Player.first_person_mode)
	
	pass
	

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://IntroScene.tscn")
		return
		
	if game_over:
		if Input.is_action_just_pressed("primary_fire"):
			get_tree().change_scene("res://IntroScene.tscn")
		return
		
	time_left -= delta
	if time_left <= 0:
		game_lost()
	pass


func collision(mover, hit):
	if hit.has_method("collided"):
		hit.collided(mover)

	if "IS_PLAYER" in hit:
		if "KILLS_PLAYER" in mover:
			player_killed(hit)
			mover.queue_free()
			pass
		pass
	pass


func player_killed(player):
	if Globals.PLAYER_INVINCIBLE:
		return
		
	if player != $Player:
		extra_lives.remove(extra_lives.find(player))
		self.big_explosion(player)
		player.queue_free()
		$HUD.update_lives_label(extra_lives.size()+1)
		return
		
	if $Player.alive == false:
		return
	
	if invincible:
		return
		
	$Player.alive = false
	self.small_explosion(player)
	#$Music.stop()
	$Player.get_node("Audio_Hit").play()
	if extra_lives.size() > 0:
		$RestartTimer.start()
	else:
		game_lost()
		pass
	pass
	
	
func restart_player():
	var idx = Globals.rnd.randi_range(0, extra_lives.size()-1)
	var extra_life : ExtraLife = extra_lives[idx]
	extra_lives.remove(idx)
	$Player.restart(extra_life.translation)
	extra_life.queue_free()
	$HUD.update_lives_label(extra_lives.size()+1)
	#$Music.play()
	
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
	

func _on_RestartPosTimer_timeout():
	if $Player.alive == false:
		return
		
	if start_pos_idx == 0:
		self.prev_start_pos0 = $Player.translation
		self.start_pos = self.prev_start_pos1
		pass
	else:
		self.prev_start_pos1 = $Player.translation
		self.start_pos = self.prev_start_pos0
		pass
		
	start_pos_idx += 1
	if start_pos_idx > 1:
		start_pos_idx = 0
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


func _on_UpdateZoneTimer_timeout():
	var zone = $Player.translation.z / -14;
	$HUD.update_zone_label(zone)

	$HUD.update_time_label(time_left)
	pass


func inc_score(amt):
	score += amt
	$HUD.update_score_label(score)
	pass
	

func check_activation(e : Spatial):
	var dist = $Player.translation.distance_to(e.translation)
	e.activated = dist < Globals.ACTIVATION_DIST
	if e.activated == false:
		var wt : int = (dist - Globals.ACTIVATION_DIST) / 8#7#6
		if wt < 1:
			wt = 1
		if wt > 8: # don't make it too long in case the player dies and moves instantly next to baddies
			wt = 8
		e.get_node("ActivationTimer").wait_time = wt
	pass


func start_end_sequence():
	$Sounds/VictoryMusic.play()
	$InvincibleTimer.stop()
	invincible = true
	end_sequence_started = true
	
	while extra_lives.size() > 0:
		var el = extra_lives[0]
		player_killed(el)
	pass
	

func finish_end_sequence():
	self.big_explosion($Highway/Ship)
	$Highway/Ship.queue_free()
	self.big_explosion($Highway/TheBomb)
	$Highway/TheBomb.queue_free()
	
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
