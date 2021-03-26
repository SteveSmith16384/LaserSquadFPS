extends Spatial


func _ready():
	if $AudioStreamPlayer:
		$AudioStreamPlayer.play()

	var tween : Tween = $Tween
	#var tween2 : Tween = get_node("Tween2")
	if tween:
		tween.interpolate_property($OmniLight, "light_energy",
			1.0, 0.0, 
			4,
			Tween.TRANS_SINE, Tween.EASE_IN )
		tween.repeat = false
		tween.start()
	pass
	
	
func _on_Timer_timeout():
	queue_free()
	pass
