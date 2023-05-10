class_name Logger extends MenuContent

@onready var scrollable:Scrollable = $Scrollable

func _ready():
	super._ready()
	scrollable.connect("pressed_cancel",func():close())

func _append(_name,_msg):
	scrollable.add_item(_name)
	scrollable.add_item(_msg)

func open():
	reload()
	scrollable.scrolling_bottom()
	scrollable.enable()
	super.open()

func reload():
	scrollable._clear_rows()
	for text in System.message_log.slice(System.message_log.size()-100,System.message_log.size()):
		_append(text["name"],text["msg"])
