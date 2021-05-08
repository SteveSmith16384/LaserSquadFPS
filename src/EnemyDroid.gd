extends KinematicBody

onready var bullet_class = preload("res://Bullet.tscn")
var droid_corpse_class = preload("res://DestroyedRobot.tscn")

var main : Main
var player : Spatial

var player_in_area = false
var can_see_player = false
var destroyed = false

const move_speed = 2
var patrol_path : Path
var patrol_points
var patrol_index = 0
var velocity = Vector2.ZERO
var closest

func _ready():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	pass


func _process(delta):
	if destroyed:
		self.rotation_degrees.y += delta * 1000
		return
		
	if player == null:
		return
		
	if player.alive == false:
		$MeshInstance.visible = true
		return
		
	if player_in_area && can_see_player:
		var us = self.translation
		var them = player.translation
		var wtransform = global_transform.looking_at(Vector3(them.x,us.y,them.z),Vector3(0,1,0))
		var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), delta*5)
		self.global_transform = Transform(Basis(wrotation), global_transform.origin)
		pass
	pass


func _physics_process(delta):
	if destroyed:
		return
		
	if player == null:
		return
		
	if player.alive == false:
		return
		
	var space_state = get_world().direct_space_state
	var players_eyes = player.get_eyes_position()
	var result : Dictionary = space_state.intersect_ray($Eyes.global_transform.origin, players_eyes, [player]);
	#var ray_pos = self.translation#$RayCast.global_transform.origin
	#var pos = players_eyes - ray_pos
	#$RayCast.set_cast_to(pos)
	#var c = $RayCast.get_collider()
	#can_see_player = not $RayCast.is_colliding()# result.empty()
	can_see_player = result.empty()
	$MeshInstance.visible = can_see_player

	if player_in_area == false or can_see_player == false:
		if patrol_points == null:
			patrol_points = main.get_patrol_points(self);
			patrol_index = 0
			# SHow debugging nodes
			main.get_node("SternersHouse/FinalDest").translation = patrol_points[patrol_points.size()-1]
			main.get_node("SternersHouse/FinalDest").translation.y = 0.5
			
		var target = patrol_points[patrol_index]
		target.y = 0
		# Debugging node
		main.get_node("SternersHouse/ImmedDest").translation = target

		if translation.distance_to(target) < 1:
			patrol_index = patrol_index + 1
			if patrol_index >= patrol_points.size():
				patrol_points = null
				#print("End of route")
				return
			
		# Look at
		var us = self.translation
		var them = target#.translation
		var wtransform = global_transform.looking_at(Vector3(them.x,us.y,them.z),Vector3(0,1,0))
		var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), delta*5)
		self.global_transform = Transform(Basis(wrotation), global_transform.origin)

		velocity = (target - translation).normalized() * move_speed
		if velocity.length() > 0:
			var dist = move_and_slide(velocity) # todo - check for collision with robots
			dist.y = 0
			if dist.length() <= 0:
				print("Cannot move!")
				patrol_points = null
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
	if player == null:
		return
		
	if player.alive == false:
		return
	
	if main.game_over:
		return
		
	if destroyed:
		return
		
	if player_in_area && can_see_player:
		var bullet : Bullet = bullet_class.instance()
		main.add_child(bullet)
		bullet.transform = global_transform
		bullet.translation = get_node("Muzzle").global_transform.origin
	pass


func hit_by_bullet():
	main.small_explosion(self)
	destroyed = true
	$Death_Timer.start()
	$MeshInstance.visible = true
	pass

func _on_Death_Timer_timeout():
	main.big_explosion(self)
	
	var corpse = droid_corpse_class.instance()
	corpse.translation = self.translation
	main.add_child(corpse)
	
	queue_free()
	pass # Replace with function body.
