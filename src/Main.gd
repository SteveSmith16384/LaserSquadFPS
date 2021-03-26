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
var entities_to_remove = []
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
	

#func collect_entities_UNUSED(owner):
#	for child in owner.get_children():
#		if "ENTITY" in child:
#			if "REMOVE_IF_OOV" in child:
#				entities_to_remove.push_back(child)
#		collect_entities(child)
#	pass
#	
	
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


func push(e, normal : Vector3):
	e.sliding_data = SlidingData.new()
	e.sliding_data.offset = normal * -150
	pass
	
	
func slide(e, delta: float):
	#for e in self.entities_sliding:
	if e.sliding_data != null:
		e.sliding_data.offset.y = 0
		var off = e.sliding_data.offset * delta #e.translation.linear_interpolation(e.sliding_data, e.inter)
		#print("Moving by " + str(off))
		var change = e.move_and_slide(off, Vector3.UP)
		if e.get_slide_count() > 0:
			var col = e.get_slide_collision(0);
			#print("Hit " + col.get_collider().to_string())
			if "sliding_data" in col.get_collider():
				push(col.get_collider(), col.normal)
		#else:
		#	print("change by " + str(change))
		e.sliding_data.offset = e.sliding_data.offset * 0.9
		if e.sliding_data.offset.length() < 0.1:
			e.sliding_data = null
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


func add_remove_entities_UNUSED():
	#print("Num entities before: " + str(level.get_child_count()))
	for entity in entities_to_remove:
		if entity == null:
			#todo - entities_to_remove.remove(entity)
			continue

		if entity.get_parent_spatial() != null:
			# Remove entity?
			var dist = entity.global_transform.origin.distance_to($Player.translation)
			if dist > Globals.VIEW_RANGE + 11:
				entity.original_position = entity.global_transform.origin
				entity.original_parent = entity.get_owner()
				level.remove_child(entity)
				#print("Removing entity " + entity.name)
		else:
			# Add entity
			var dist = entity.original_position.distance_to($Player.translation)
			if dist < Globals.VIEW_RANGE + 10:
				entity.original_parent.add_child(entity)
				if entity.has_method("added"):
					entity.added()
					#print("Added entity " + entity.name)

	#print("Num entities after: " + str(level.get_child_count()))
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
	
