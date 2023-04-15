class_name World extends Node2D

func _ready():
	disable()
	enable()

func disable():
	if System.is_start_main:
		System.emit_signal("disable")
		await System.finished_fade

func enable():
	if System.is_start_main:
		System.emit_signal("enable")
