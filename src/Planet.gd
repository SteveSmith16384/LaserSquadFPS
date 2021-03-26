extends MeshInstance

var player : Player
var offset : Vector3

func _ready():
	var main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	offset = transform.origin - player.transform.origin
	pass


func _process(delta):
	if player:
		self.translation = player.transform.origin + offset
	pass
