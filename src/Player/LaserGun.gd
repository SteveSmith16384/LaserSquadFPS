extends Spatial

const laser_fire_rate = 0.2
const clip_size = 8
const laser_reload_rate = 0.8#1

export var default_position : Vector3

var main : Main
var player : Player

var current_ammo = clip_size
var can_laser_fire = true
var laser_reloading = false

var bullet_class

func _ready():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")

	current_ammo = clip_size	
	
	bullet_class = preload("res://Bullet.tscn")
	pass

	
func _process(delta):
	if player.alive == false:
		return
		
	if Input.is_action_pressed("primary_fire") and can_laser_fire:
		if current_ammo > 0 and not laser_reloading:
			fire_bullet()
		elif not laser_reloading:
			reload()
	
	if Input.is_action_just_pressed("reload") and not laser_reloading:
		reload()
	pass


func fire_bullet():
	can_laser_fire = false
	current_ammo -= 1
	var bullet : Bullet = bullet_class.instance()
	var main : Main = get_tree().get_root().get_node("Main")
	main.add_child(bullet)
	$ShotAudio.play()
	
	bullet.transform = global_transform
	bullet.translation = get_node("Muzzle").global_transform.origin
	
	yield(get_tree().create_timer(laser_fire_rate), "timeout")

	if current_ammo <= 0:
		reload()
		
	can_laser_fire = true
	pass


func reload():
	laser_reloading = true

	yield(get_tree().create_timer(laser_reload_rate), "timeout")

	current_ammo = clip_size
	laser_reloading = false
	pass
