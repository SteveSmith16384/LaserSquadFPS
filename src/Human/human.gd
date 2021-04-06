extends Spatial

func _ready():
	#set_texture_to_white()
	
	#anim("Run")
	#anim("Die")
	#anim("Idle")
	#anim("Work")
	#anim("Punch")
	anim("Run")
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


func set_texture_to_white():
	var tex = load("res://Human/side_white.png")
	var c = $"Human Armature/Human_Mesh".get_surface_material_count()
	var mat2 = $"Human Armature/Human_Mesh".mesh.surface_get_material(0)
	#var mat = $"Human Armature/Human_Mesh".mesh.get_surface_material(6)
	mat2.albedo_texture = tex
