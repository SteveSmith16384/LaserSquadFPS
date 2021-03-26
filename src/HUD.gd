extends Node2D


func _ready():
	$WellDone.visible = false
	$GameOver.visible = false

	$DebugMode.visible = !Globals.RELEASE_MODE
	
	if Globals.SHOW_FPS:
		$Timer.start()
	pass


func update_zone_label(zone : int):
	$InGame/HBoxContainer/ZoneLabel.set_text("ZONE: " + str(41-zone))
	pass

	
func update_time_label(s : int):
	$InGame/HBoxContainer/TimeLabel.set_text("TIME: " + str(s))
	pass
	
	
func update_score_label(s : int):
	$InGame/HBoxContainer/ScoreLabel.set_text("SCORE: " + str(s))
	pass
	
func update_lives_label(s : int):
	$InGame/HBoxContainer/LivesLabel.set_text("LIVES: " + str(s))
	pass
	

func show_well_done():
	$InGame.visible = false
	$WellDone.visible = true
	pass


func show_game_over():
	$InGame.visible = false
	$GameOver.visible = true
	pass
	

func _on_Timer_timeout():
	$FPSLabel.set_text("FPS: " + str(Engine.get_frames_per_second()))
	pass


func show_targetter(show: bool):
	$InGame/Reticule.visible = show
	pass
