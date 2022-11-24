class_name Modal extends CanvasLayer

signal finished_open
signal finished_close
signal pressed_button1
signal pressed_button2
signal pressed_button3

@export var anim_time := 0.5

@onready var background := $background
@onready var panel := $panel
@onready var button := [
	$panel/margin/contents/buttons/button1,
	$panel/margin/contents/buttons/button2,
	$panel/margin/contents/buttons/button3]

func _ready():
	background.visible = false
	panel.scale = Vector2.ZERO
	panel.pivot_offset = panel.size/2
	button[0].pressed.connect(func():emit_signal("pressed_button1"))
	button[1].pressed.connect(func():emit_signal("pressed_button2"))
	button[2].pressed.connect(func():emit_signal("pressed_button3"))
	disable()

func open(time:=anim_time):
	background.visible = true
	if 0<time :
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(panel, "scale", Vector2.ONE,time)
		tween.play()
		await tween.finished
	else :
		panel.scale = Vector2.ONE
	enable()
	emit_signal("finished_open")

func close(time:=anim_time):
	background.visible = false
	disable()
	if 0<time :
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(panel, "scale", Vector2.ZERO,time)
		tween.play()
		await tween.finished
	else :
		panel.scale = Vector2.ZERO
	emit_signal("finished_close")

func disable():
	for btn in button : btn.focus_mode = Control.FOCUS_NONE

func enable():
	for btn in button : btn.focus_mode = Control.FOCUS_ALL
