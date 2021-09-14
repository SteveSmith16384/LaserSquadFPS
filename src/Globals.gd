extends Node

const VERSION = "1.1"
const RELEASE_MODE = false
const DEBUG_START_POS = false and !RELEASE_MODE # If true, uses StartPos in main for player's start position
const NO_ENEMIES = false and !RELEASE_MODE
const SHOW_FPS = true and !RELEASE_MODE
#const PLAYER_INVINCIBLE = false and !RELEASE_MODE

const START_TIME_SECONDS = 250

var rnd : RandomNumberGenerator
var player_nums = []


func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	pass
	
