class_name ExtraLife
extends KinematicBody

const IS_PLAYER = true

var main
var move_dir = Vector3(0, 0, -1)

func _ready():
	main = get_tree().get_root().get_node("Main")
	if main:
		main.extra_lives.push_back(self)
	pass


func _process(delta):
	if main:
		var offset = move_dir * 100
		move_and_slide(offset * delta, Vector3.UP)
	pass
