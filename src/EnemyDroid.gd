extends KinematicBody

var bullet_class = preload("res://Bullet.tscn")

var main : Main
var player : Spatial

var player_in_area = false
var can_see_player = false


func _ready():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
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
		#self.rotation_degrees.y += 80 * delta * dir
		pass
	pass


func _physics_process(delta):
	if player_in_area:
		#todo only every so often
		var space_state = get_world().direct_space_state
		var result : Dictionary = space_state.intersect_ray(self.translation, player.translation, [player]);
		can_see_player = result.empty()
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
