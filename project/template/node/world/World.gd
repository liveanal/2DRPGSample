class_name World extends Node2D

@onready var tilemap := $TileMap

func _ready():
	System.emit_signal("disable")
	
	# Mainキャラにカメラを設定
	var main:Character = get_children().filter(func(c):return c is Character and c.is_main)[0]
	System.get_camera_manager().target = main
	
	# マップサイズからlimitを設定
	var map_size:Rect2i = tilemap.get_used_rect()
	var min:Vector2 = tilemap.map_to_local(map_size.position)
	var max:Vector2 = tilemap.map_to_local(map_size.size)
	System.get_camera_manager().set_limit(min,max)
	
	# カメラ有効化
	System.get_camera_manager().enabled = true
