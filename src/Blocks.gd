extends KinematicBody

var sliding_data : SlidingData

var main : Main

func _ready():
	main = get_tree().get_root().get_node("Main")
	pass


func _process(delta):
	main.slide(self, delta)
	pass
	
	
