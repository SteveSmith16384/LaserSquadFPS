extends KinematicBody

const KILLS_PLAYER = true

const SPEED = 5

var main : Main
var player : Player

var x_dir = 1
var move = Vector3(1, 0, 0)
var rot = Vector3(0, 1, 0)

var model_idx = 1
var model_idx_change = 1

var activated = false

func _ready():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	pass


func _process(delta):
	if main.end_sequence_started:
		self.queue_free()
		return
		
	if activated == false:
		return
		
	rotate(rot, delta * 5)
	
	move.x = x_dir
	var c = self.move_and_collide(move * delta * SPEED)
	if c != null:
		x_dir = x_dir * -1
		main.collision(self, c.collider)
		pass
	pass


func _on_Timer_timeout():
	if activated == false:
		return
		
	$MeshInstance1.visible = false
	$MeshInstance2.visible = false
	$MeshInstance3.visible = false
	$MeshInstance4.visible = false
	
	model_idx += model_idx_change
	if model_idx > 4:
		model_idx = 3
		model_idx_change = -1
	elif model_idx == 0:
		model_idx = 2
		model_idx_change = 1
		
	get_node("MeshInstance" + str(model_idx)).visible = true
	pass


func _on_ActivationTimer_timeout():
#	var dist = player.translation.distance_to(self.translation)
#	self.activated = dist < Globals.ACTIVATION_DIST
	main.check_activation(self)
	pass
