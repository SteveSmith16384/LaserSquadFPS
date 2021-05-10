extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Node2D/VersionLabel.set_text("VERSION " + Globals.VERSION);
	pass


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		return

	if Input.is_action_just_pressed("primary_fire"):
		#get_tree().change_scene("res://Main.tscn")
		get_tree().change_scene("res://SelectPlayersScene.tscn")
		return

	$LogoSpatial.rotation_degrees.x += 120 * delta
	while $LogoSpatial.rotation_degrees.x > 360:
		$LogoSpatial.rotation_degrees.x -= 360
	pass


func _on_Timer_timeout():
	$Node2D/StartLabel.visible = !$Node2D/StartLabel.visible
	pass
