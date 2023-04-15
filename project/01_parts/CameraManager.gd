class_name CameraManager extends Node

@export var target:Node2D
@export var follow_target:bool = true
@export var enabled:bool = true:
	set(val):
		camera.enabled = val
	get:
		return camera.enabled
@export var zoom:float = 1.5
@export var rotate:float = 0.0

@onready var camera := $camera
@onready var _min := $min
@onready var _max := $max

func _ready():
	Logging.assert_error("E_C01",[get_parent().name], _min.position==Vector2.ZERO and _max.position==Vector2.ZERO)
	
	camera.limit_left = int(_min.position.x)
	camera.limit_right = int(_max.position.x)
	camera.limit_top = int(_min.position.y)
	camera.limit_bottom = int(_max.position.y)
	camera.enabled = enabled
	camera.ignore_rotation = true
	camera.limit_smoothed = true
	camera.zoom = Vector2(zoom,zoom)

func _process(_delta):
	if target!=null and follow_target :
		camera.position = target.position
		camera.zoom = Vector2(zoom,zoom)
		camera.rotation = rotate
		camera.force_update_scroll()
