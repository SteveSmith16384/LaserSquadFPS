extends Spatial

func _ready():
	Globals.player_nums.clear()
	pass
	
	
func _process(delta):
	if Globals.SINGLE_PLAYER_MODE:
		Globals.player_nums.push_back(0)
		get_tree().change_scene("res://Main.tscn")
		pass
		
	if Input.is_action_just_pressed("primary_fire0"):
		if Globals.player_nums.has(0) == false:
			append_text("Player 0 added")
			Globals.player_nums.push_back(0)
		pass
		
	if Input.is_action_just_pressed("primary_fire1"):
		if Globals.player_nums.has(1) == false:
			append_text("Player 1 added")
			Globals.player_nums.push_back(1)
		pass

	if Input.is_action_just_pressed("jump0"):
		get_tree().change_scene("res://Main.tscn")
		pass


func append_text(s):
	$Node2D/TextEdit.text = $Node2D/TextEdit.text + s + "\n"
	pass
	

