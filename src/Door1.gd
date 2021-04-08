extends Spatial

var pos_x = 0
var opening = false
var closing = false

func _ready():
	pass


func _process(delta):
	if opening:
		$RightDoor.translation.x += delta
		if $RightDoor.translation.x > 1:
			$RightDoor.translation.x = 1
			opening = false
			$CloseTimer.start()
	elif closing:
		$RightDoor.translation.x -= delta
		if $RightDoor.translation.x < 0:
			$RightDoor.translation.x = 0
			closing = false
			
			
	$LeftDoor.translation.x = -$RightDoor.translation.x
	pass


func _on_Area_body_entered(body):
	if opening:
		return
		
	if body != $LeftDoor && body != $RightDoor:
		opening = true
		closing = false
		$CloseTimer.stop()
		$CloseTimer.start()
		$Audio_OpenClose.play()
	pass


func _on_CloseTimer_timeout():
	closing = true
	$Audio_OpenClose.play()
	pass


