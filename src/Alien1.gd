extends KinematicBody

const destroyed_by_bullet = true
const KILLS_PLAYER = true
const SCORE = 100

const SPEED = 5

var main : Main
var player : Player

var x_dir = 0
var z_dir = 1
var move = Vector3(0, 0, 1)
var rot = Vector3(0, 1, 0)

var activated = false

func _ready():
	main = get_tree().get_root().get_node("Main")
	if main:
		player = main.get_node("Player")
	pass


func _process(delta):
	if main == null:
		return
		
	if main.end_sequence_started:
		self.queue_free()
		return
		
	if activated == false:
		return
		
	rotate(rot, delta * 5)
	
	move.x = x_dir
	move.z = z_dir
	var c = self.move_and_collide(move * delta * SPEED)
	if c != null:
		get_random_dir()
		#z_dir = z_dir * -1
		main.collision(self, c.collider)
		pass
	pass


func get_random_dir():
	x_dir = 0
	z_dir = 0

	var i = Globals.rnd.randi_range(1, 4)
	match i:
		1: x_dir = 1
		2: x_dir = -1
		3: z_dir = 1
		4: z_dir = -1
	pass



func _on_ActivationTimer_timeout():
	if main:
		main.check_activation(self)
	pass
