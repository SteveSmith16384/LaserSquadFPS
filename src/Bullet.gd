class_name Bullet 
extends KinematicBody

const SPEED = 20

var main : Main
var player : Player
var dir : Vector3

func _ready():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	#$AudioStreamPlayer.play()
	pass


func _process(delta):
	var dir = global_transform.basis.z * delta * -1 * SPEED
	var col : KinematicCollision = move_and_collide(dir)
	if col:
		if "destroyed_by_bullet" in col.collider:
			main.small_explosion(col.collider)
			if "SCORE" in col.collider:
				main.inc_score(col.collider.SCORE)
			col.collider.queue_free()
			self.queue_free()
		else:
			main.play_clang()
			main.tiny_explosion(self)
			if "sliding_data" in col.collider:
				main.push(col.collider, col.normal)
		queue_free()
	pass


func _on_Timer_timeout():
	queue_free()
	pass
