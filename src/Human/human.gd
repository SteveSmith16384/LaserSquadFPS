extends Spatial

func _ready():
	#anim("Run")
	#anim("Die")
	#anim("Idle")
	#anim("Work")
	#anim("Punch")
	anim("Walk")
	pass
	

func anim(a):
	var anim = $"Human Armature/AnimationPlayer"
	if anim.current_animation != a:
		anim.play(a)
		var an = anim.get_animation(a)
		if a == "Die":
			an.set_loop(false)
		else:
			an.set_loop(true)

