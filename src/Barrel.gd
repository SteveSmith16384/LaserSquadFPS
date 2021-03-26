extends KinematicBody

var sliding_data : SlidingData

var main : Main

func _ready():
	main = get_tree().get_root().get_node("Main")
	pass


func _process(delta):
	if main:
		self.translation.y = 0 # In case it has been pushed down
		main.slide(self, delta)
	pass
	
	
