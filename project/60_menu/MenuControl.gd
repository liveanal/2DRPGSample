class_name MenuControl extends Control

signal finished_open
signal finished_close

func _ready():
	close()

func open():
	enable()
	visible = true
	emit_signal("finished_open")

func close():
	visible = false
	disable()
	emit_signal("finished_close")

func enable():
	set_process_input(true)

func disable():
	set_process_input(false)
