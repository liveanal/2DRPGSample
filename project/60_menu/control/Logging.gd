class_name Logging extends MenuControl

@onready var scrollable:Scrollable = $Scrollable

func _ready():
	super._ready()
	scrollable.connect("pressed_cancel",func():close())

func open():
	scrollable.scrolling_bottom()
	scrollable.enable()
	super.open()

func append(name,msg):
	scrollable.add_item(name)
	scrollable.add_item(msg)
