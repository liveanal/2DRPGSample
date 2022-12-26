class_name CameraManager extends Node

@export var target:Node2D
@export var follow_target:bool = true
@export var current:bool = true : 
	set(val):
		$_camera.current = val
	get:
		return $_camera.current
@export var zoom:float = 1.501
@export var rotate:float = 0.0

@onready var camera := $camera
@onready var min := $min
@onready var max := $max

func _ready():
	camera.limit_left = int(min.position.x)
	camera.limit_right = int(max.position.x)
	camera.limit_top = int(min.position.y)
	camera.limit_bottom = int(max.position.y)
	camera.current = current
	camera.ignore_rotation = true
	camera.limit_smoothed = true
	camera.zoom = Vector2(zoom,zoom)

func _process(delta):
	if target!=null and follow_target :
		camera.position = target.position
		camera.zoom = Vector2(zoom,zoom)
		camera.rotation = rotate
		camera.force_update_scroll()
