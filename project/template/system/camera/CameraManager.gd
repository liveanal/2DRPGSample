class_name CameraManager extends Node

@export var target:Node2D
@export var follow_target:bool = true
@export var enabled:bool = true:
	set(val):
		enabled = val
		if camera!=null: camera.enabled = val
	get:
		return enabled
@export var zoom:float = 1.5
@export var rotate:float = 0.0

@onready var camera := $camera
@onready var minpos := $min
@onready var maxpos := $max

func _ready():
	System.assert_error("E_C01",[get_parent().name], enabled and minpos.position==Vector2.ZERO and maxpos.position==Vector2.ZERO)
	
	camera.limit_left = int(minpos.position.x)
	camera.limit_right = int(maxpos.position.x)
	camera.limit_top = int(minpos.position.y)
	camera.limit_bottom = int(maxpos.position.y)
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

func set_limit(_min:Vector2, _max:Vector2):
	minpos.position = _min
	maxpos.position = _max
	camera.limit_left = int(minpos.position.x)
	camera.limit_right = int(maxpos.position.x)
	camera.limit_top = int(minpos.position.y)
	camera.limit_bottom = int(maxpos.position.y)
