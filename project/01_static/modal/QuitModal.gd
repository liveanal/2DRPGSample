class_name QuitModal extends Modal

signal pressed_cansel

func _ready():
	super._ready()
	connect("pressed_button1",_on_pressed_cansel)
	connect("pressed_button2",_on_pressed_ok)

func _on_pressed_cansel():
	await close(anim_time)
	emit_signal("pressed_cansel")

func _on_pressed_ok():
	disable()
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func open(time:=anim_time):
	await super.open(time)
	button[0].grab_focus()
