class_name Main
extends Spatial

var invincible = false

var tiny_expl = preload("res://TinyExplosion.tscn")	
var small_expl = preload("res://SmallExplosion.tscn")	
var big_expl = preload("res://BigExplosion.tscn")	

var time_left : float
var game_over = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	time_left = Globals.START_TIME_SECONDS
	$HUD.update_time_label(time_left)
	
	var head_class = preload("res://Player/Head.tscn")

	# Add a player. Possible values 0 - 3. Returns a TextureRect with some extra goodies attached
	var render = $Splitscreen.add_player(0)
	var cam = head_class.instance()# $Player/Head
	$Player.set_head(cam)
	render.viewport.add_child(cam)
	
	#-------------------------------
	render = $Splitscreen.add_player(1)

	render = $Splitscreen.add_player(2)

	self.set_first_person(true)#$Player.first_person_mode)
	
	# Preload explosions
	self.big_explosion($DirectionalLight)
	self.small_explosion($DirectionalLight)
	self.tiny_explosion($DirectionalLight)
	pass
	

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://IntroScene.tscn")
		return
		
	if game_over:
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
		
	$Player/Human.anim("Die")
	$Player.alive = false
	self.small_explosion($Player)
	game_lost()
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
	

func sterner_killed():
	$Sounds/VictoryMusic.play()
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
