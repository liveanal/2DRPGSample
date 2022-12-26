class_name Logging extends CanvasLayer

@onready var scrollable := $Scrollable

func _ready():
	close()

func append(name,msg):
	scrollable.add_item(name)
	scrollable.add_item(msg)

func open():
	visible = true
	scrollable.is_input = true
	await get_tree().process_frame
	scrollable.modulate = Color(Color.WHITE,1.0)
	scrollable.scrolling_bottom()

func close():
	scrollable.is_input = false
	visible = false
	scrollable.modulate = Color(Color.WHITE,0.0)
