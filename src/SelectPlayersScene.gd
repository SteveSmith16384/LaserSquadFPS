extends Spatial

func _process(delta):
	if Input.is_action_just_pressed("primary_fire"):
		print("Player 1 added")
		Globals.player_nums.push_back(1)
		pass
		
	if Input.is_action_just_pressed("primary_fire2"):
		print("Player 2 added")
		Globals.player_nums.push_back(2)
		pass

	if Input.is_action_just_pressed("jump"):
		get_tree().change_scene("res://Main.tscn")
		pass

