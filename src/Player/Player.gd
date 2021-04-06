class_name Player
extends KinematicBody


const speed = 3.5#3.5#4
const acceleration = 25
const mouse_sensitivity = 0.3

var main : Main

onready var head = $Head
var first_person_camera : Camera
var third_person_camera : Camera
#var gun

var velocity = Vector3()
var camera_x_rotation = 0
var start_y : float
var alive = true

var play_footstep : bool = false
var actually_play_footstep : bool = true

var first_person_mode = true

# Third person cam settings
var mouseSensitivity = 0.1
var yaw_y : float = 0.0
var pitch_x : float = -45.0
var origin : Vector3 = Vector3()
var target_dist : float = 6.0
var actual_dist : float = 0.0

# Gun settings
const laser_fire_rate = 0.2
const clip_size = 8
const laser_reload_rate = 0.8#1
var current_ammo = clip_size
var can_laser_fire = true
var laser_reloading = false

var bullet_class

func _ready():
	main = get_tree().get_root().get_node("Main")
	first_person_camera = find_node("FirstPersonCamera")
	third_person_camera = find_node("ThirdPersonCamera")
	#gun = find_node("gun")

	start_y = self.translation.y

	toggle_camera()
	update_camera()

	current_ammo = clip_size
	bullet_class = preload("res://Bullet.tscn")
	pass
	
	
func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90: 
			first_person_camera.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta
#
		# 3rd-person cam
		var mouseVec : Vector2 = event.get_relative()
		yaw_y = head.rotation_degrees.y#fmod(yaw_y - mouseVec.x * mouseSensitivity, 360.0)
		pitch_x = max(min(pitch_x - mouseVec.y * mouseSensitivity, 90.0), -90.0)
		update_camera()

	pass


func update_camera():
	third_person_camera.set_rotation(Vector3(deg2rad(pitch_x), deg2rad(yaw_y), 0.0))
	third_person_camera.set_translation(origin - actual_dist * third_person_camera.project_ray_normal(get_viewport().get_visible_rect().size * 0.5))
	
	if alive:
		if first_person_mode:
			var rot = head.rotation_degrees.y
			#$MeshSpatial.rotation_degrees.y = rot
			$Human.rotation_degrees.y = rot + 180
		else:
			#$MeshSpatial.rotation_degrees.y = third_person_camera.rotation_degrees.y
			$Human.rotation_degrees.y = third_person_camera.rotation_degrees.y + 180
	pass


func _process(delta):
	if alive == false:
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
	#todo $ShotAudio.play()
	
	bullet.transform = $Head.global_transform
	bullet.translation = get_node("Head/Muzzle").global_transform.origin
	
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
	
func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_first_person"):
		if self.first_person_mode:
			self.target_dist = 6
		else:
			self.target_dist = 0

	if Input.is_action_just_pressed("camera_fwd"):
		target_dist = target_dist / 2
		if (target_dist <= 1):
			target_dist = 0
		self.update_camera()
	if Input.is_action_just_pressed("camera_back"):
		if (target_dist <= 0):
			target_dist = 1
		target_dist = target_dist * 2
		self.update_camera()
		
	if actual_dist != target_dist:
		actual_dist += (target_dist-actual_dist) * delta * 3
		self.update_camera()
		set_first_person_mode(actual_dist <= 1)
		
	if alive == false:
		velocity.x = 0
		velocity.z = 0
		move_and_slide(velocity, Vector3.UP)
		return
		
	play_footstep = false
	
	var head_basis
	if first_person_mode:
		head_basis = head.get_global_transform().basis
	else:
		head_basis = third_person_camera.get_global_transform().basis
		
	var direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		play_footstep = true
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward"):
		play_footstep = true
		direction += head_basis.z
	
	if Input.is_action_pressed("move_left"):
		play_footstep = true
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right"):
		play_footstep = true
		direction += head_basis.x
	
	direction.y = 0
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	if get_slide_count() > 0:
		var coll = get_slide_collision(0).get_collider()
		main.collision(self, coll)
		pass
	
	if play_footstep:
		play_footstep()
		$Human.anim("Run")
	else:
		$Human.anim("Idle")
	
	pass
	
	
func toggle_camera():
	first_person_mode = !first_person_mode
	set_first_person_mode(first_person_mode)
	pass
	
	
func set_first_person_mode(b):
	if first_person_mode == b:
		return
		
	first_person_mode = b

	#find_node("MeshSpatial").visible = !first_person_mode
	$Human.visible = !first_person_mode
	main.set_first_person(first_person_mode)

	self.first_person_camera.current = first_person_mode
	self.third_person_camera.current = !first_person_mode
	
	self.update_camera();
	pass


func play_footstep():
	if actually_play_footstep == false:
		return
		
	actually_play_footstep = false
	var sfx = load("res://Assets/sfx/metal_interactions/metal_button_press" + str(Globals.rnd.randi_range(1, 2)) + ".wav")
	$AudioStreamPlayer_Generic.stream = sfx
	$AudioStreamPlayer_Generic.play()
	
	yield(get_tree().create_timer(.45), "timeout")
	actually_play_footstep = true
	pass


func restart(trans):
	self.translation = trans
	self.translation.y = start_y
	alive = true
	pass
	
	
func hit_by_bullet():
	main.player_hit()
	pass
	
