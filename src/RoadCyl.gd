extends CSGCylinder

var rot = Vector3(1, 0, 0)

func _ready():
	pass


func _process(delta):
	rotate(rot, delta * 1)
	pass
