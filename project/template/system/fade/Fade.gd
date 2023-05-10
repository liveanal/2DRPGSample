class_name Fade extends CanvasLayer

signal finished

@onready var fade := $fade

var time:float
var before:Color
var after:Color
var start := false
var seek := 0.0

func init(_color:Color):
	fade.color = _color

func start_in(_time:float, _next:Color=fade.color):
	time = _time
	seek = 0.0
	before = fade.color
	after = Color(_next,1.0)
	start = true

func start_out(_time:float, _next:Color=fade.color):
	time = _time
	seek = 0.0
	before = fade.color
	after = Color(_next,0.0)
	start = true

func _process(_delta):
	if start:
		seek += _delta
		fade.color = lerp(before,after,seek/time)
	if time < seek :
		start = false
		emit_signal("finished")
