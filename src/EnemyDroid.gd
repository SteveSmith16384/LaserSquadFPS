extends KinematicBody

var bullet_class = preload("res://Bullet.tscn")

var main : Main
var player : Spatial

var player_in_area = false
var can_see_player = false

const move_speed = 1#00
var patrol_path : Path
var patrol_points
var patrol_index = 0
var velocity = Vector2.ZERO
var closest

func _ready():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	
	#patrol_path = main.get_node("SternersHouse/Path")
	#patrol_points = patrol_path.get_curve().get_baked_points()
	#closest = patrol_path.get_curve().get_closest_point(self.translation)
	pass


func _process(delta):
	if player_in_area && can_see_player:
		var us = self.translation
		var them = player.translation
		var wtransform = global_transform.looking_at(Vector3(them.x,us.y,them.z),Vector3(0,1,0))
		var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), delta*5)
		self.global_transform = Transform(Basis(wrotation), global_transform.origin)
		pass
	else:
		#self.rotation_degrees.y += 10 * delta
		pass
	pass


func _physics_process(delta):
	if player_in_area:
		#todo only every so often
		var space_state = get_world().direct_space_state
		var result : Dictionary = space_state.intersect_ray(self.translation, player.translation, [player]);
		can_see_player = result.empty()
	else:
#		if !patrol_path:
#			return
		if patrol_points == null:
			patrol_points = main.get_patrol_points(self);
			main.get_node("SternersHouse/FinalDest").translation = patrol_points[patrol_points.size()-1]
			main.get_node("SternersHouse/FinalDest").translation.y = 0.5
			patrol_index = 0
			print("Got patrol points")
			
		var target = patrol_points[patrol_index]
		target.y = 0
		main.get_node("SternersHouse/ImmedDest").translation = target
		if translation.distance_to(target) < 1:
			patrol_index = patrol_index + 1# = wrapi(patrol_index + 1, 0, patrol_points.size())
			if patrol_index >= patrol_points.size():
				patrol_points = null
				print("End of route")
				return
#			target = patrol_points[patrol_index]
#			target.y = 0
			print("Next target: " + str(target))

		velocity = (target - translation).normalized() * move_speed
		velocity = move_and_slide(velocity)
	pass
	
	
func _on_Area_body_entered(body):
	if body == player:
		player_in_area = true
	pass


func _on_Area_body_exited(body):
	if body == player:
		player_in_area = false
	pass


func _on_ShootTimer_timeout():
	if player_in_area && can_see_player:
		var bullet : Bullet = bullet_class.instance()
		main.add_child(bullet)
		bullet.transform = global_transform
		bullet.translation = get_node("Muzzle").global_transform.origin
	pass
