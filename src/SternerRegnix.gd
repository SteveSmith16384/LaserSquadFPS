extends KinematicBody

var bullet_class = preload("res://Bullet.tscn")

var main : Main
var player : Spatial

var player_in_area = false
var can_see_player = false

func _ready():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")

	#get_node("Human").set_texture_to_white()
	get_node("Human").anim("Idle")
	pass


func _process(delta):
	if player.alive == false:
		$Human.visible = true
		return
		
	if main.game_over:
		return
		
	if true or (player_in_area && can_see_player):
		var us = self.translation
		var them = player.translation
		var wtransform = global_transform.looking_at(Vector3(them.x,us.y,them.z),Vector3(0,1,0))
		var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), delta*5)
		self.global_transform = Transform(Basis(wrotation), global_transform.origin)
		
		#var human = $Human#.get_node("Human Armature")
		#print("Self rot: " + str(rotation_degrees.y))
		#print("Human rot: " + str(human.rotation_degrees.y))
		#human.rotation_degrees.y = self.rotation_degrees.y
	pass


func _physics_process(delta):
	if player.alive == false:
		return
		
	var space_state = get_world().direct_space_state
	var players_eyes = player.get_eyes_position()
	var result : Dictionary = space_state.intersect_ray($Eyes.global_transform.origin, players_eyes, [player]);
	can_see_player = result.empty()
	$Human.visible = can_see_player
	
	
func _on_Area_body_entered(body):
	if body == player:
		player_in_area = true
	pass


func _on_Area_body_exited(body):
	if body == player:
		player_in_area = false
	pass


func _on_ShootTimer_timeout():
	if player.alive == false:
		return
		
	if main.game_over:
		return
		
	if player_in_area && can_see_player:
		$Audio_Shoot.play()
		var bullet : Bullet = bullet_class.instance()
		main.add_child(bullet)
		bullet.transform = global_transform
		bullet.translation = get_node("Muzzle").global_transform.origin
	pass


func hit_by_bullet():
	$Audio_Scream.play()
	get_node("Human").anim("Die")
	main.big_explosion(self)
	main.sterner_killed()
