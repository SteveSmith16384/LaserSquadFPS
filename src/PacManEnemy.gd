extends KinematicBody

const destroyed_by_bullet = true
const KILLS_PLAYER = true
const SCORE = 300

const SPEED = 6

var main : Main
var player : Player

var x_dir = 0.5
var z_dir = 0.5
var move = Vector3(0, 0, 1)
var rot = Vector3(0, 1, 0)

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
		
	rotate(rot, delta * 3)
	
	move.x = x_dir
	move.z = z_dir
	var c = self.move_and_collide(move.normalized() * delta * SPEED)
	if c != null:
		get_random_dir()
		main.collision(self, c.collider)
		pass
	pass


func get_random_dir():
	x_dir = 0
	z_dir = 0

	var i = Globals.rnd.randi_range(1, 8)
	match i:
		1: x_dir = 1
		2: x_dir = -1
		3: z_dir = 1
		4: z_dir = -1
		5: 
			x_dir = .5
			z_dir = .5
		6:
			x_dir = -.5
			z_dir = .5
		7:
			x_dir = .5
			z_dir = -.5
		8:
			x_dir = -.5
			z_dir = -.5

	pass


func _on_ActivationTimer_timeout():
#	var dist = player.translation.distance_to(self.translation)
#	self.activated = dist < Globals.ACTIVATION_DIST
	main.check_activation(self)
	pass


func _on_ChangeDirTimer_timeout():
	get_random_dir()
	pass


func _on_AnimTimer_timeout():
	if activated == false:
		return
		
	$Models/MeshInstance1.visible = false
	$Models/MeshInstance2.visible = false
	$Models/MeshInstance3.visible = false
	$Models/MeshInstance4.visible = false
	
	var current_id = Globals.rnd.randi_range(1, 4)
	self.get_node("Models/MeshInstance" + str(current_id)).visible = true
	pass
