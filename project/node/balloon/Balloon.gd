class_name Balloon extends Node2D

signal finished_open
signal finished_close

@export var auto_play := false
@export var anim_time := 0.0
@export_group("close setting")
@export var auto_close := false
@export var wait_time  := 1.5

func _ready():
	visible = false
	if auto_play : open()

func open():
	var default_scale = Vector2(scale)
	
	visible = true
	scale = Vector2.ZERO
	if 0<anim_time:
		var tween := get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).tween_property(self,"scale",default_scale,anim_time)
		tween.play()
		await tween.finished
	else:
		scale = Vector2.ONE
	
	emit_signal("finished_open")
	
	if auto_close:
		await get_tree().create_timer(wait_time).timeout
		close()

func close():
	if 0<anim_time:
		var tween := get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(self,"position",position+Vector2(0,-10),anim_time)
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(self,"modulate",Color(modulate.r,modulate.g,modulate.b,0.0),anim_time)
		tween.play()
		await tween.finished
	
	queue_free()
	emit_signal("finished_close")
