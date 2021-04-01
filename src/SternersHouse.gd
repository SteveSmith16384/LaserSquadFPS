extends Spatial



func _ready():
	place_droids()
	pass # Replace with function body.


func place_droids():
	var droid_start_positions = $DroidStartPositions
	var droids = get_tree().get_nodes_in_group("droid")
	for droid in droids:
		var idx = Globals.rnd.randi_range(0, droid_start_positions.get_child_count()-1)
		droid.translation = droid_start_positions.get_child(idx).translation;
		droid_start_positions.remove_child(droid_start_positions.get_child(idx))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
