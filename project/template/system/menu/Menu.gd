@tool
class_name Menu extends CanvasLayer

signal finished_open
signal finished_close

@export var labels:Array[MenuLabel]:
	set(val):
		labels = val
		_init_label()
	get:
		return labels
@export var theme:Theme:
	set(val):
		theme = val
		_init_label()
	get:
		return theme

@onready var select := $frame/margin/container/button_area/select
@onready var content_area := $frame/margin/container/content_area

var current_focus:Node

func _ready():
	_init_label()
	disable()
	visible = false

func _input(event):
	if event is InputEventKey:
		if !event.is_action_released("cancel") and event.is_action_pressed("cancel"):
			close()

func _init_label():
	if select!=null:
		for child in select.get_children():
			child.queue_free()
		for data in labels:
			if data != null:
				var btn := Button.new()
				btn.text = data.label
				btn.theme = theme
				btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER + Control.SIZE_EXPAND
				btn.connect("pressed",_pressed.bind(data))
				select.add_child(btn)

func _pressed(data:MenuLabel):
	disable()
	var content:MenuContent = data.get_menu_content()
	if content == null:
		await System.finished_modal
	else:
		content_area.add_child(content)
		content.open()
		await content.finished_close
		content.queue_free()
	enable()

func open():
	enable()
	visible = true
	emit_signal("finished_open")

func close():
	disable()
	visible = false
	emit_signal("finished_close")

func enable():
	if current_focus!=null:
		current_focus.grab_focus()
	else:
		select.get_child(0).grab_focus()
	set_process_input(true)

func disable():
	current_focus = get_viewport().gui_get_focus_owner()
	if current_focus!=null:
		current_focus.release_focus()
	set_process_input(false)
