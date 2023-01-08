class_name Logging extends Control

signal pressed_cancel

@onready var scrollable:Scrollable = $Scrollable

func _ready():
	scrollable.connect("pressed_cancel",func():emit_signal("pressed_cancel"))
	close()

func append(name,msg):
	scrollable.add_item(name)
	scrollable.add_item(msg)

func open():
	scrollable.enable()
	visible = true
	await get_tree().process_frame
	scrollable.modulate = Color(Color.WHITE,1.0)
	scrollable.scrolling_bottom()

func close():
	scrollable.disable()
	visible = false
	scrollable.modulate = Color(Color.WHITE,0.0)
