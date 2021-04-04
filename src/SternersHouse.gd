extends Spatial



func _ready():
	place_droids()
	
	#var start = Vector3(8, 0, 2)
	#var end = Vector3(13, 0, 6)
	#var path = $Navigation.get_simple_path(start, end)
	pass


func place_droids():
	var droid_start_positions = $DroidStartPositions
	var droids = get_tree().get_nodes_in_group("droid")
	for droid in droids:
		var idx = 0#todo Globals.rnd.randi_range(0, droid_start_positions.get_child_count()-1)
		droid.translation = droid_start_positions.get_child(idx).translation;
		droid_start_positions.remove_child(droid_start_positions.get_child(idx))
	pass


func get_rnd_destination():
	var points = $RoutePoints# $Path.curve.get_baked_points();
	var dest = points.get_node("RoutePoint" + str(Globals.rnd.randi_range(1, points.get_child_count())))
	return dest.translation
	

func get_route(start, end):
	var route = $Navigation.get_simple_path(start, end)
	if route.size() == 0:
		print("No route!")
	route.append(end)
	return route


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
