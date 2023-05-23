class_name MenuContent extends Control

signal finished_open
signal finished_close

# パーティメンバー
@export var party_member:Array[Character]:
	set(val):
		party_member = val
	get:
		return party_member

func _ready():
	visible = false
	disable()

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
