class_name World extends Node2D

@export var camera_margin:int = 100 
@onready var tilemap := $TileMap

func _ready():
	if System.is_main_start:
		System.emit_signal("disable")
	
	# マップサイズからlimitを設定
	var map_size:Rect2i = tilemap.get_used_rect()
	var min:Vector2 = tilemap.map_to_local(map_size.position) - Vector2.ONE*camera_margin
	var max:Vector2 = tilemap.map_to_local(map_size.size) + Vector2.ONE*camera_margin
	System.get_camera_manager().set_limit(min,max)
	
	# カメラ有効化
	System.get_camera_manager().enabled = true
