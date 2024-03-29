class_name Fade extends CanvasLayer

signal finished

@export var color := Color.BLACK
@export var time := 1.0

@onready var fade := $fade

var fade_in := false
var fade_out := false
var start := false
var seek := 0.0

func _process(delta):
	if !start and (fade_in or fade_out):
		fade.color = Color(color)
		start = true
	elif start and (fade_in or fade_out): 
		seek += delta
		if fade_in :
			fade.color = Tween.interpolate_value(
				Color(color.r,color.g,color.b,0.0),
				Color(color.r,color.g,color.b,1.0),
				seek,
				time,
				Tween.TRANS_LINEAR,
				Tween.EASE_OUT
			)
		elif fade_out :
			fade.color = Color(color.r,color.g,color.b,1.0) - Tween.interpolate_value(
				Color(color.r,color.g,color.b,0.0),
				Color(color.r,color.g,color.b,1.0),
				seek,
				time,
				Tween.TRANS_LINEAR,
				Tween.EASE_OUT
			)
	if time < seek :
		fade_in = false
		fade_out = false
		start = false
		seek = 0.0
		emit_signal("finished")

func start_in(t:=self.time,c:=self.color):
	if !fade_in && !fade_out:
		fade_in = true
		self.time = t
		self.color = Color(c.r,c.g,c.b,0.0)

func start_out(t:=self.time,c:=self.color):
	if !fade_in && !fade_out:
		fade_out = true
		self.time = t
		self.color = Color(c.r,c.g,c.b,1.0)
