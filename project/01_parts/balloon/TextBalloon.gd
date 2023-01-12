class_name TextBalloon extends Balloon

@export_multiline var text:String:
	set(val):
		text = val
		_check_text()
	get:
		return text
@export var pos_offset:Vector2 = Vector2.ZERO
@export var font_size:int = 16

@onready var frame:NinePatchRect = $frame
@onready var margin:MarginContainer = $frame/margin
@onready var label:RichTextLabel = $frame/margin/text

var lines:=[]
var max_height:=0
var max_width:=0

func _check_text():
	var reg := RegEx.new()
	reg.compile("\\[.*\\]")
	lines = reg.sub(text,"",true).split("\n")
	max_height = lines.size()
	max_width=0
	for line in lines:
		var width := Utility.get_bytesize(line)
		if max_width<width : max_width=width

func open():
	margin.set("theme_override_constants/margin_left",frame.patch_margin_left)
	margin.set("theme_override_constants/margin_top",frame.patch_margin_top)
	margin.set("theme_override_constants/margin_right",frame.patch_margin_right)
	margin.set("theme_override_constants/margin_bottom",frame.patch_margin_bottom)
	
	label.text = "[center][font_size=%d]%s[/font_size][/center]" % [font_size,text]
	frame.size += Vector2(max_width,max_height) * Vector2(font_size*2/3, font_size)
	frame.pivot_offset = Vector2(frame.size.x/2,frame.size.y)
	frame.position = -Vector2(frame.size.x/2,frame.size.y)
	
	position += pos_offset
	super.open()
