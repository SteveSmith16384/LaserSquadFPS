extends KinematicBody

var move_dir = Vector3(0, 0, -1)

var sliding_data : SlidingData

var main : Main
var moving = false

func _ready():
	main = get_tree().get_root().get_node("Main")
	pass


func _process(delta):
	if sliding_data:
		sliding_data.offset.x = 0
		sliding_data.offset.y = 0
		main.slide(self, delta)
	
	if main.extra_lives.size() == 0: # Since there's nothing pushing it
		return
		
	var offset = move_dir * 100
	move_and_slide(offset * delta, Vector3.UP)
	if get_slide_count() > 0:
		if moving:
			$AudioAmbience.stop()
			$AudioBlocked.play()
			pass
		moving = false
		if main.end_sequence_started:
			var coll = get_slide_collision(0).get_collider()
	else:
		if moving == false:
			$AudioAmbience.play()
			$AudioMoving.play()
		moving = true
	pass


func _on_FinishArea_body_entered(body):
	if body == self:
		main.start_end_sequence()
		pass


func _on_FinishArea_body_exited(body):
	if body == self:
		main.finish_end_sequence()
	pass
